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

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: TextField(
          focusNode: this._focusNode,
          onSubmitted: this._searchBooks,
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

  _searchBooks(String newQuery) async {
    setState(() {
      this.query = newQuery;
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
        itemCount: books.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          final book = books[index];
          return BookCard(
            book: book,
            onTap: () => widget.onSelectBook(book),
          );
        });
  }
}
