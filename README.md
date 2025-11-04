# Introduction
Experience a whole new level of convenience with just a single line of wrapping—no complex setup or controller required—for effortless infinite scroll loading.

> [!IMPORTANT]
> The `Scrollable` widget (e.g., ListView) must use a `NestedScrollController` or a subclass. Using a regular ScrollController will cause the infinite scroll pagination to fail.

## Why Use This Library?
This package eliminates the usual boilerplate of infinite scroll implementations. Simply wrap your scrollable widget with `InfiniteScrollPagination`, and it just works. Perfect for adding infinite scroll to lists, grids, or any scrollable content **without worrying about controllers or extra setup.**

## Usage

```dart
InfiniteScrollPagination(
    reverse: false,
    isEnabled: ...,
    onLoadMore: ...,
    loadingIndicator: ...,
    child: ListView.builder(
        shrinkWrap: true, // Must always be set to true
        itemCount: _items.length,
        itemBuilder: (context, index) {
            return Text(_items[index]);
        },
    ),
),
```
