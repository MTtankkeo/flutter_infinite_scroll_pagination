import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_infinite_scroll_pagination/flutter_infinite_scroll_pagination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    "Ensures the scrollable child of InfiniteScrollPagination lazily builds with shrinkWrap: true.",
    (tester) async {
      tester.view.physicalSize = Size(200, 200);
      tester.view.devicePixelRatio = 1.0;

      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: .ltr,
          child: InfiniteScrollPagination(
            onLoadMore: () async {},
            isEnabled: true,
            child: ListView.builder(
              itemCount: 1000,
              shrinkWrap: true,
              scrollCacheExtent: .pixels(0),
              itemBuilder: (context, index) {
                buildCount += 1;
                return SizedBox(height: 50);
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Expect only the visible portion of the list to be built.
      // If more than ~10 items are built for a 200px viewport,
      // something’s very wrong or physics itself collapsed.
      expect(
        buildCount,
        lessThan(10),
        reason: "Only visible items should be built lazily",
      );
    },
  );

  testWidgets('does not reload during a ballistic tick before the disabled rebuild', (tester) async {
    final response = Completer<void>();
    final enabled = ValueNotifier(true);
    addTearDown(enabled.dispose);

    int requestCount = 0;

    await tester.pumpWidget(
      ValueListenableBuilder<bool>(
        valueListenable: enabled,
        builder: (context, value, child) {
          return Directionality(
            textDirection: .ltr,
            child: InfiniteScrollPagination(
              isEnabled: value,

              // Reproduce the issue during ballistic scrolling by
              // loading before reaching the end.
              preloadOffset: 100,
              loadingIndicator: const SizedBox(height: 40),
              onLoadMore: () async {
                requestCount++;
                await response.future;
                enabled.value = false;
              },
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: 30,
                itemBuilder: (context, index) {
                  return const SizedBox(height: 50);
                },
              ),
            ),
          );
        },
      ),
    );

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

    // Move near the load-more boundary.
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent - 80);
    await tester.pump();

    // Trigger loading and keep ballistic scrolling active.
    await tester.drag(find.byType(ListView), const Offset(0, -40));
    (scrollable.position as ScrollActivityDelegate).goBallistic(600);
    await tester.pump(const .new(milliseconds: 16));

    expect(requestCount, 1);
    expect(scrollable.position.isScrollingNotifier.value, isTrue);

    // Complete the request between frames: the new isEnabled has not been built yet.
    response.complete();
    await tester.idle();

    expect(enabled.value, isFalse);

    // Verify that the widget remains enabled before the parent rebuilds.
    {
      final finder = find.byType(InfiniteScrollPagination);

      expect(
        tester.widget<InfiniteScrollPagination>(finder).isEnabled,
        isTrue,
      );
    }

    // The ballistic animation ticks before the scheduled parent rebuild.
    await tester.pump(const .new(milliseconds: 16));
    await tester.pumpAndSettle();
    expect(requestCount, 1);
  });
}
