import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:flutter_infinite_scroll_pagination/components/infinite_scroll_position.dart';

/// A widget that enables effortless infinite scrolling
/// by simply wrapping a scrollable child.
///
/// It works out-of-the-box with any primary scrollable widget,
/// automatically detecting the scroll boundary to trigger
/// the [onLoadMore] callback—no manual [ScrollController]
/// management is needed.
///
/// A loading indicator is displayed while new content is being fetched,
/// and its position is handled automatically based on the [reverse] property.
class InfiniteScrollPagination extends StatefulWidget {
  const InfiniteScrollPagination({
    super.key,
    this.isEnabled = true,
    this.loadingIndicator,
    this.preloadOffset = 0.0,
    this.canBouncing = true,
    this.reverse = false,
    required this.onLoadMore,
    required this.child,
  });

  /// Whether infinite scroll pagination is enabled.
  final bool isEnabled;

  /// A widget to display while loading more content (e.g., a loading spinner).
  final Widget? loadingIndicator;

  /// The distance from the bottom at which to trigger [onLoadMore].
  final double preloadOffset;

  /// Whether the loading indicator should sync with iOS-style bouncing
  /// scroll and move along with the overscroll effect.
  final bool canBouncing;

  /// Called to asynchronously load more content when scrolling approaches
  /// the loading boundary.
  ///
  /// Typically used to implement infinite scrolling. This callback should
  /// initiate an asynchronous task (e.g., network request), and once completed,
  /// new data should be appended to the existing list.
  final AsyncCallback onLoadMore;

  /// Whether the scroll view scrolls in the reverse direction.
  ///
  /// If set to true, the content is ordered from bottom to top, and the loading
  /// indicator appears at the top. This is similar to [ListView.reverse].
  ///
  /// Defaults to false.
  final bool reverse;

  /// The child widget that defines the [Scrollable] widget.
  final Widget child;

  @override
  State<InfiniteScrollPagination> createState() =>
      _InfiniteScrollPaginationState();
}

class _InfiniteScrollPaginationState extends State<InfiniteScrollPagination> {
  final InfiniteScrollPosition position = InfiniteScrollPosition();

  /// Defines the [ScrollPosition] instance detected from the current child widget.
  ScrollPosition? _scrollPosition;

  /// Whether [widget.onLoadMore] has been called and is currently awaiting a response.
  bool isLoading = false;

  /// Whether infinite scroll pagination is enabled.
  bool get isEnabled => widget.isEnabled;

  /// Applies additional scroll to the infinite scroll position
  /// when the nested scroll reaches its maximum extent.
  ///
  /// This allows the outer scrollable to "pass through" extra scroll
  /// to the inner pagination logic, enabling continuous loading.
  double _handleNestedScroll(double available, ScrollPosition scroll) {
    _scrollPosition = scroll;

    if (scroll.pixels == scroll.maxScrollExtent) {
      return position.setPixelsByDelta(available);
    }

    // Trigger load more when the remaining scroll distance
    // to the end is less than the specified preloadOffset.
    if (scroll.extentAfter < widget.preloadOffset) {
      _tryLoadMore();
    }

    return 0.0;
  }

  /// Observes iOS-style bouncing by tracking the extra scroll offset.
  /// Used so the loading indicator can sync with the bounce without
  /// consuming scroll.
  double _handleBouncing(double available, ScrollPosition scroll) {
    if (widget.canBouncing) {
      position.bouncingPixels = available;
    }

    return 0.0;
  }

  /// Attempts to load more items when the loading indicator becomes visible.
  void _tryLoadMore() async {
    if (!isEnabled) return;
    if (!isLoading) {
      isLoading = true;

      try {
        await widget.onLoadMore();
      } catch (_) {
        rethrow;
      } finally {
        /// Whether the scroll offset is large enough to require correction
        /// to account for layout reflow or overscroll.
        final shouldCorrect = position.pixels > precisionErrorTolerance;

        // Stops any ongoing scroll and applies offset correction
        // to account for the fully collapsed indicator layout.
        if (shouldCorrect && _scrollPosition != null) {
          final resolvedPixels = _scrollPosition!.pixels + position.pixels;
          final scrollDelegate = _scrollPosition as ScrollActivityDelegate;

          // Stop any ongoing scrolling activity to prevent interference.
          _scrollPosition!.beginActivity(IdleScrollActivity(scrollDelegate));

          // Corrects any offset error caused by layout reflow.
          _scrollPosition!.correctPixels(resolvedPixels);
        }

        position.setPixels(0);
        position.isVisibleNotifier.value = false;
        isLoading = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    position.isVisibleNotifier.addListener(_tryLoadMore);
  }

  @override
  void dispose() {
    position.isVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget indicator = Align(
      alignment: Alignment.center,
      child: widget.loadingIndicator ?? _defaultLoadingIndicator(),
    );

    return SizedBox.expand(
      child: Stack(
        // Sets the alignment for the entire stack containing
        // the scrollable content and the loading indicator.
        alignment:
            widget.reverse ? Alignment.bottomCenter : Alignment.topCenter,
        children: [
          _RenderInfiniteScrollPagination(
            position: position,
            reverse: widget.reverse,
            children: [
              NestedScrollConnection(
                onBouncing: _handleBouncing,
                onPreScroll: _handleNestedScroll,
                onPostScroll: _handleNestedScroll,
                child: NestedScrollControllerScope(
                  factory: (context) => NestedScrollController(),
                  builder: (context, _) => widget.child,
                ),
              ),

              // When the indicator does not need to be rendered at all.
              if (isEnabled)
                ListenableBuilder(
                  listenable: position.isVisibleNotifier,
                  builder: (context, child) {
                    // Controls the loading indicator animation based on visibility.
                    // Runs animations only when the indicator is actually visible.
                    return TickerMode(
                      enabled: position.isVisibleNotifier.value,
                      child: indicator,
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns a loading indicator widget based on the current platform.
  /// Uses [CupertinoActivityIndicator] for iOS or macOS
  /// and [CircularProgressIndicator] for others (e.g. Android).
  Widget platformLoadingIndicator(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
        ? CupertinoActivityIndicator()
        : CircularProgressIndicator();
  }

  /// Returns the default loading indicator with vertical padding.
  Widget _defaultLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: platformLoadingIndicator(context),
    );
  }
}

/// A widget that wraps its children for infinite scroll pagination.
class _RenderInfiniteScrollPagination extends MultiChildRenderObjectWidget {
  const _RenderInfiniteScrollPagination({
    required super.children,
    required this.position,
    required this.reverse,
  });

  final InfiniteScrollPosition position;
  final bool reverse;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _InfiniteScrollPaginationRenderBox(
      position: position,
      reverse: reverse,
    );
  }
}

/// The render box responsible for laying out and painting the
/// body and loading indicator for infinite scroll.
///
/// It listens to [InfiniteScrollPosition] changes to trigger layout
/// updates, adjusts painting offsets based on scroll position,
/// and updates visibility state of the loading indicator.
class _InfiniteScrollPaginationRenderBox extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _ParentData> {
  _InfiniteScrollPaginationRenderBox({
    required this.position,
    required this.reverse,
  }) {
    position.addListener(markNeedsLayout);
  }

  final InfiniteScrollPosition position;
  final bool reverse;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ParentData) {
      child.parentData = _ParentData();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final Offset translatedOffset = Offset(0, -this.position.pixels);

    // Adjusts the position to compensate for the offset modification.
    return result.addWithPaintOffset(
      offset: translatedOffset,
      position: position,
      hitTest: (result, position) {
        return firstChild!.hitTest(result, position: position);
      },
    );
  }

  @override
  void performLayout() {
    final RenderBox body = firstChild!;
    final RenderBox? indicator = childAfter(body);

    // Perform layout for measuring an intrinsic size of the children.
    body.layout(constraints, parentUsesSize: true);
    indicator?.layout(
      BoxConstraints(maxWidth: constraints.maxWidth),
      parentUsesSize: true,
    );

    // Calculate the remaining height and update position information.
    final double availableHeight = constraints.maxHeight - body.size.height;
    final double indicatorHeight = indicator?.size.height ?? 0.0;
    position
      ..viewHeight = availableHeight
      ..extent = indicatorHeight;

    // Set the total size, considering the maximum height constraint.
    final totalHeight = body.size.height + indicatorHeight;
    size = Size(body.size.width, totalHeight.clamp(0.0, constraints.maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox body = firstChild!;
    final RenderBox? indicator = childAfter(body);

    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      PaintingContext innerContext,
      Offset innerOffset,
    ) {
      // Calculate the remaining vertical space in
      // the viewport after laying out the body.
      final double availableHeight = size.height - body.size.height;

      // In reverse mode, align the body to the bottom of the viewport.
      // The overscroll amount [position.pixels] then pushes it down.
      final Offset bodyOffset = reverse
          ? offset.translate(0, availableHeight + position.pixels)
          : offset.translate(0, -position.pixels);

      // Calculate the indicator's offset to place it just above
      // (in reverse mode) or below (in normal mode) the body.
      final double nestedOffset = reverse
          ? availableHeight - (indicator?.size.height ?? 0.0) + position.pixels
          : body.size.height - position.pixels;

      Offset indicatorOffset = offset.translate(0, nestedOffset);
      indicatorOffset = indicatorOffset.translate(0, -position.bouncingPixels);

      // The indicator is visible if there's space to load more
      // content or if an overscroll is currently in progress.
      final bool isVisible = indicator != null &&
          position.extent != 0.0 &&
          position.viewHeight + position.pixels > precisionErrorTolerance;

      // Defers updating the notifier until the next frame to avoid triggering a rebuild
      // during the paint phase, preventing the "Build scheduled during frame" assertion.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        position.isVisibleNotifier.value = isVisible;
      });

      innerContext.paintChild(body, bodyOffset);

      // Paints the loading indicator only if it is visible.
      if (isVisible) {
        innerContext.paintChild(indicator, indicatorOffset);
      }
    });
  }
}

/// ParentData used by [_InfiniteScrollPaginationRenderBox]
/// to store positional information for each child.
class _ParentData extends ContainerBoxParentData<RenderBox> {}
