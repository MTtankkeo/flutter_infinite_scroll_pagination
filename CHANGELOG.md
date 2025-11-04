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
