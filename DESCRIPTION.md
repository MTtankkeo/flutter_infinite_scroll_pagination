# shrinkWrap: true, is it really a performance problem? ❌

No, not at all! Many developers mistakenly assume that setting `shrinkWrap: true` forces a `ListView` or `GridView` to build all items at once, causing a performance drop. In reality, this package ensures that **lazy building behavior remains intact**, and `shrinkWrap` only affects layout calculations. Here’s why:

## How the package handles layout

1. **Custom RenderBox for layout control**  
   - `_InfiniteScrollPaginationRenderBox` measures and lays out the scrollable child (`ListView` or `GridView`) along with the loading indicator.  
   - It respects the parent’s constraints by clamping the total height:  
     ```dart
     // Perform layout for measuring an intrinsic size of the children.
     body.layout(constraints, parentUsesSize: true);

     size = Size(body.size.width, totalHeight.clamp(0.0, constraints.maxHeight));
     ```  
     This means the child never expands beyond the available viewport, regardless of `shrinkWrap`.

2. **Lazy building is preserved**  
   - `ListView.builder` or `GridView.builder` still builds items on demand.  
   - The render box only calculates **the visible portion** needed for layout and painting. It does **not** force all items to be built, even with `shrinkWrap: true`.  

3. **NestedScrollController integration**  
   - The package uses `NestedScrollController` and `NestedScrollConnection` to manage extra scroll offsets when the user reaches the scroll boundary.  
   - Scroll events are handled efficiently and passed through to the child scrollable only when necessary, without triggering unnecessary builds.

4. **Stacked loading indicator**  
   - The loading indicator is positioned using the render box, aligned relative to the child layout (`body.size.height`) and the current scroll offset (`position.pixels`).  
   - Its visibility is tracked via `position.isVisibleNotifier`, but **this does not trigger full rebuilds** of the list; it only paints the indicator when needed.

## Key takeaway

- `shrinkWrap` only determines how the scrollable widget calculates its size within the parent.  
- The package’s custom render object ensures that **layout calculations remain efficient** and **lazy item building is unaffected**.  
- In practice, setting `shrinkWrap: true` **does not introduce performance issues**, and the recommendation is simply for better layout behavior when item heights are not guaranteed.

So, feel free to use `shrinkWrap` when necessary—it’s not a “performance killer,” but a tool to handle layout flexibility safely.

## "No! Using RenderShrinkWrappingViewport!"

**Yes, and so what?** 

`RenderShrinkWrappingViewport` **still supports lazy building**. Let me clarify this once and for all:

### The Reality of RenderShrinkWrappingViewport ✅

1. **Lazy building is preserved**
   - Items are still built on-demand, not all at once
   - Viewport culling works exactly the same way
   - Only visible items (plus a small buffer) are actually built and rendered

### Challenge to Critics 🎯

If you believe `RenderShrinkWrappingViewport` inherently causes performance issues:

1. Show me **concrete benchmarks** comparing:
   - 15 items with `shrinkWrap: false`
   - 15 items with `shrinkWrap: true`
   
2. Prove that lazy building is disabled (hint: it's not)

### Bottom Line

**"Using RenderShrinkWrappingViewport" is not an argument.** 

It's just an implementation detail that:
- ✅ Still does lazy building
- ✅ Still culls off-screen items
- ✅ Has negligible performance difference with small item counts
- ✅ Works perfectly fine within bounded constraints

Stop repeating dogma without evidence. **Test it yourself** if you don't believe it.

## "No! I tried it and experienced performance issues at another project and package!" ❌

You might think that `shrinkWrap: true` inherently causes performance degradation, but in most cases, the problem lies elsewhere:

- Performance drops typically occur when `shrinkWrap` is used **inside nested scroll views** or when the parent has **unbounded constraints** (i.e., the child can grow indefinitely).  
- In such cases, the scrollable cannot determine its size properly, leading developers to wrap it in additional scroll views or complex layouts—this is what actually causes the slowdown.  
- It is **not the `shrinkWrap` property itself** that hurts performance; it’s the way it’s misused in combination with an unbounded or nested scroll environment.  

In other words, `shrinkWrap` can safely be used when the parent provides bounded constraints, and the package ensures that lazy building and layout calculations remain efficient. Misusing it in unbounded or poorly structured scroll setups is what triggers the observed performance issues, not `shrinkWrap` itself.

So, does this help put your mind at ease now? 😊
