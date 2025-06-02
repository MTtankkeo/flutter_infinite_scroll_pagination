# Introduction
Experience a whole new level of convenience with just a single line of wrapping—no complex setup or controller required—for effortless infinite scroll loading.

> See Also, If you want the change-log by version for this package. refer to [Change Log](CHANGELOG.md) for details.

## Usage

```dart
InfiniteScrollPagination(
    isEnabled: ...,
    onLoadMore: ...,
    child: ListView.builder(
        shrinkWrap: true,
        itemCount: _items.length,
        itemBuilder: (context, index) {
            return Text(_items[index]);
        },
    ),
),
```