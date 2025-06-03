import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:flutter_infinite_scroll_pagination/components/infinite_scroll_position.dart';

class InfiniteScrollPagination extends StatefulWidget {
  const InfiniteScrollPagination({
    super.key,
    this.isEnabled = true,
    this.loadingIndicator,
    required this.onLoadMore,
    required this.child,
  });

  /// Whether infinite scroll pagination is enabled.
  final bool isEnabled;

  /// A widget to display while loading more content (e.g., a loading spinner).
  final Widget? loadingIndicator;

  /// TODO: The distance from the bottom at which to trigger [onLoadMore].
  final double preloadOffset = 0.0;

  /// Called to asynchronously load more content when scrolling approaches the loading boundary.
  ///
  /// Typically used to implement infinite scrolling. This callback should initiate
  /// an asynchronous task (e.g., network request), and once completed,
  /// new data should be appended to the existing list.
  final AsyncCallback onLoadMore;

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

  double _handleNestedScroll(double available, ScrollPosition scroll) {
    _scrollPosition = scroll;

    if (scroll.pixels == scroll.maxScrollExtent) {
      return position.setPixelsByDelta(available);
    }

    return 0.0;
  }

  void _tryLoadMore() async {
    if (!isLoading) {
      isLoading = true;
      await widget.onLoadMore();

      // Corrects any offset error caused by layout reflow.
      _scrollPosition?.correctPixels(_scrollPosition!.pixels + position.pixels);

      position.setPixels(0);
      position.isVisibleNotifier.value = false;
      isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    position.isVisibleNotifier.addListener(_tryLoadMore);
  }

  @override
  Widget build(BuildContext context) {
    return _RenderInfiniteScrollPagination(
      position: position,
      children: [
        NestedScrollConnection(
          onPreScroll: _handleNestedScroll,
          onPostScroll: _handleNestedScroll,
          child: PrimaryScrollController(
            controller: NestedScrollController(),
            scrollDirection: Axis.vertical,
            child: widget.child,
          ),
        ),

        if (widget.isEnabled)
          Align(
            alignment: Alignment.center,
            child: widget.loadingIndicator ?? _defaultLoadingIndicator(),
          ),
      ],
    );
  }

  Widget _defaultLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: CircularProgressIndicator(),
    );
  }
}

class _RenderInfiniteScrollPagination extends MultiChildRenderObjectWidget {
  const _RenderInfiniteScrollPagination({
    required super.children,
    required this.position,
  });

  final InfiniteScrollPosition position;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _InfiniteScrollPaginationRenderBox(position: position);
  }
}

class _InfiniteScrollPaginationRenderBox extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _ParentData> {
  _InfiniteScrollPaginationRenderBox({required this.position}) {
    position.addListener(markNeedsLayout);
  }

  final InfiniteScrollPosition position;

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
      final Offset bodyOffset = offset.translate(0, -position.pixels);
      final double nestedOffset = body.size.height - position.pixels;
      final Offset indicatorOffset = offset.translate(0, nestedOffset);

      final bool isVisible =
          indicator != null &&
          position.extent != 0.0 &&
          position.viewHeight + position.pixels > precisionErrorTolerance;

      position.isVisibleNotifier.value = isVisible;

      innerContext.paintChild(body, bodyOffset);

      if (isVisible) {
        innerContext.paintChild(indicator, indicatorOffset);
      }
    });
  }
}

class _ParentData extends ContainerBoxParentData<RenderBox> {}
