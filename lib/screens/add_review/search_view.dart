import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

import 'package:galpi/components/book_card/main.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/remotes/fetch_books.dart';

typedef void OnSelectBook(Book book);

class SearchView extends StatefulWidget {
  final OnSelectBook onSelectBook;

  SearchView({this.onSelectBook});

  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final FocusNode _focusNode = new FocusNode();

  String query = '';
  final StreamController<String> _queryStreamController = StreamController();

  Observable queryObservable;

  _SearchViewState() {
    Observable(_queryStreamController.stream)
        .distinct()
        .debounceTime(const Duration(milliseconds: 1000))
        .listen(_onQueryChange);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: TextField(
          focusNode: this._focusNode,
          onChanged: (v) {
            _queryStreamController.sink.add(v);
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
              labelText: '제목, 저자, 출판사', border: OutlineInputBorder()),
        ),
      ),
      Expanded(child: _buildContent()),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _queryStreamController.close();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  _onQueryChange(String newQuery) {
    setState(() {
      query = newQuery;
    });
  }

  Widget _buildContent() {
    if (query == '') {
      return _buildPlaceholder();
    }

    return FutureBuilder(
        future: fetchBooks(query: query),
        builder: (context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data == null || snapshot.data.length == 0
                ? _buildPlaceholder()
                : _buildRows(snapshot.data);
          } else if (snapshot.hasError) {
            return Flexible(child: Text("${snapshot.error}"));
          }

          return Container(width: 0, height: 0);
        });
  }

  Widget _buildPlaceholder() {
    return Container(
      alignment: Alignment.center,
      child: Text('검색 결과가 없습니다.'),
    );
  }

  Widget _buildRows(List<Book> books) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16.0),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCard(
            book: book,
            onTap: () => widget.onSelectBook(book),
          );
        });
  }
}
