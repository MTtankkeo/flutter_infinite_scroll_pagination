## 1.0.0-beta1
- A initial version.

## 1.0.0-beta2
- Fixed an issue where incorrect exceptions from the Flutter SDK were triggered in certain debug environments.

## 1.0.0
- **Support for reverse-scrolling:** Introduced a `reverse` property. This property should be set to `true` to align with a child `ScrollView` (like a `ListView`) that also has its `reverse` property set to `true`. This ensures the loading indicator correctly appears at the top, matching the child's upward-scrolling behavior. It is designed for use cases like chat applications where the list is anchored to the bottom and older content is loaded at the top.