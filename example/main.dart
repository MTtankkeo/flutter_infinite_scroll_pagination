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
          child: TestView(),
        ),
      ),
    );
  }
}

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  final List<String> _items = [];

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollPagination(
      isEnabled: _items.length < 100,
      onLoadMore: () async {
        await Future.delayed(Duration(seconds: 1));

        setState(() {
          for (int i = 0; i < 30; i++) {
            _items.add("Hello, World! ${_items.length}");
          }
        });
      },
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