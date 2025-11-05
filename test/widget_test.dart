import 'package:flutter/material.dart';
import 'package:flutter_infinite_scroll_pagination/flutter_infinite_scroll_pagination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    "Ensures the scrollable child of InfiniteScrollPagination lazily builds with shrinkWrap: true.",
    (tester) async {
      // Reality check test. This test exists because some people still believe
      // that setting `shrinkWrap: true` forces ListView to build every item at once.
      // It doesn’t. It never did. It never will.
      //
      // But since debates are louder than facts, we’re letting
      // the test runner handle the argument for us.
      //
      // But they’ll probably still trust their feelings over facts.
      // Well, it is what it is.

      tester.view.physicalSize = Size(200, 200);
      tester.view.devicePixelRatio = 1.0;

      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InfiniteScrollPagination(
            onLoadMore: () async {},
            isEnabled: true,
            child: ListView.builder(
              itemCount: 1000,
              cacheExtent: 0.0,
              shrinkWrap: true,
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

      tester.printToConsole(
        "Wow…! It actually passed! But wait—does that mean"
        "Flutter engine is lying right now!? What a shocker!!",
      );
    },
  );
}
