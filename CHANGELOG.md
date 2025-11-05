## 1.0.0-beta1
- A initial version.

## 1.0.0-beta2
- Fixed an issue where incorrect exceptions from the Flutter SDK were triggered in certain debug environments.

## 1.0.0
- **Support for reverse-scrolling:** Introduced a `reverse` property. This property should be set to `true` to align with a child `ScrollView` (like a `ListView`) that also has its `reverse` property set to `true`. This ensures the loading indicator correctly appears at the top, matching the child's upward-scrolling behavior. It is designed for use cases like chat applications where the list is anchored to the bottom and older content is loaded at the top.

## 1.1.0
- Updated the default loading indicator to automatically switch between `CupertinoActivityIndicator` and `CircularProgressIndicator` based on the current theme and platform.

- Fixed an issue where the `InfiniteScrollPagination` widget would not function correctly if its parent widget imposed strict size constraints, such as `Expanded` widget.

## 1.1.1
- Fixed scroll offset calculation to correctly handle collapsed indicator area on iOS with **BouncingScrollPhysics**, ensuring smooth correction despite bounce effects.

## 1.1.2
- Mdofiyed README.md about shrinkWrap.

- Added DESCRIPTION.md.

## 1.2.0
- Added `preloadOffset` option to define the distance from the bottom at which to trigger `onLoadMore`.

- Added `canBouncing` option to determine whether the loading indicator should sync with iOS-style bouncing scroll and move along with the overscroll effect.

- Magically resolved a severe performance issue related to a non-existent `shrinkWrap` in the layout calculation and structure of this package. 😏 (In reality, nothing was changed—because there was nothing to fix.)

# 1.2.1
- Fixed an issue where the loading indicator, although correctly excluded from rendering when not needed, would still receive ticks if layout calculation or tree retention was required for scrolling, causing the next frame to be scheduled and a re-render to occur even when the indicator was not visible.
