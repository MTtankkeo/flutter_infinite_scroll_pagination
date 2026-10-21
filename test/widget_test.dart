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
}
