import 'package:flutter/material.dart';

import 'package:galpi/models/book.dart';

import './search_view.dart';

typedef OnSelect = Future<void> Function({Book book});

class SearchBookArguments {
  final OnSelect onSelect;

  const SearchBookArguments({this.onSelect});
}

class SearchBook extends StatefulWidget {
  final SearchBookArguments arguments;

  const SearchBook({Key key, @required this.arguments}) : super(key: key);

  @override
  _SearchBookState createState() => _SearchBookState();
}

class _SearchBookState extends State<SearchBook> {
  FutureBuilder<List<Book>> searchResultBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 독후감 작성'),
        centerTitle: false,
      ),
      body: SearchView(onSelectBook: widget.arguments.onSelect),
    );
  }
}
