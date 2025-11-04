import 'package:flutter/material.dart';
import 'package:flutter_infinite_scroll_pagination/flutter_infinite_scroll_pagination.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Example(),
        ),
      ),
    );
  }
}

/// Example view showing how to use InfiniteScrollPagination.
class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final List<String> _items = [];

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollPagination(
      // Whether infinite scrolling is enabled, set false
      // if you reached the end or want to stop loading.
      isEnabled: _items.length < 100,

      // Callback executed when the user scrolls to the bottom,
      // Perform your async data fetching here.
      onLoadMore: () async {
        await Future.delayed(Duration(seconds: 1));

        setState(() {
          for (int i = 0; i < 30; i++) {
            _items.add("Hello, World! ${_items.length}");
          }
        });
      },

      // The child must be a Scrollable widget, (e.g., ListView, GridView)
      // Must set `shrinkWrap`: true to ensure proper layout inside InfiniteScrollPagination.
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Text(_items[index]);
        },
      ),
    );
  }
}
