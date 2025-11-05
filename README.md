# Introduction
Experience a whole new level of convenience with just a single line of wrapping—no complex setup or controller required—for effortless infinite scroll loading.

> [!IMPORTANT]
> The `Scrollable` widget (e.g., ListView, GridView) must use a `NestedScrollController` or a subclass. Using a regular ScrollController will cause the infinite scroll pagination to fail.

## Preview
The GIF below demonstrates the package in action. Please note that due to compression, the animation may appear distorted or choppy.

![preview](https://github.com/MTtankkeo/flutter_infinite_scroll_pagination/raw/refs/heads/main/image/preview.gif)

## Why Use This Library?
This package eliminates the usual boilerplate of infinite scroll implementations. Simply wrap your scrollable widget with `InfiniteScrollPagination`, and it just works. Perfect for adding infinite scroll to lists, grids, or any scrollable content **without worrying about controllers or extra setup.**

## Usage

> [!NOTE]
> 💡 Some beginners mistakenly believe that setting `shrinkWrap: true` causes a ListView or GridView to build all items at once. This is only partially correct.<br><br>
> In this package, using `shrinkWrap` does **not** result in any performance degradation.
> If you want a more technical and objective explanation of why, please refer to [DESCRIPTION.md](DESCRIPTION.md).

```dart
InfiniteScrollPagination(
    reverse: false,
    isEnabled: ...,
    onLoadMore: ...,
    preloadOffset: 500, // Default is zero.
    loadingIndicator: ...,
    child: ListView.builder(
        // Set to true in some cases.
        // (But, lazy building is still maintained)
        shrinkWrap: true,
        itemCount: _items.length,
        itemBuilder: (context, index) {
            return Text(_items[index]);
        },
    ),
),
```
