import 'package:flutter/material.dart';

import 'package:booklog/components/book_card/main.dart';
import 'package:booklog/models/book.dart';
import 'package:booklog/remotes/fetch_books.dart';

class AddBook extends StatefulWidget {
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  FocusNode _focusNode = new FocusNode();
  Book selectedBook;
  FutureBuilder<List<Book>> searchResultBuilder;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('새 리뷰'),
        ),
        body: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              focusNode: _focusNode,
              onSubmitted: _searchBooks,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  labelText: '책 제목',
                  prefixIcon: _focusNode.hasFocus
                      ? IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            _focusNode.unfocus();
                          })
                      : Icon(Icons.search),
                  border: OutlineInputBorder()),
            ),
          ),
          Expanded(
              child: searchResultBuilder == null
                  ? Container(
                      alignment: Alignment.center, child: Text('검색 결과가 없습니다.'))
                  : searchResultBuilder)
        ]));
  }

  _searchBooks(String query) async {
    setState(() {
      this.searchResultBuilder = FutureBuilder(
          future: fetchBooks(query: query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data == null
                  ? Container(
                      width: 0,
                      height: 0,
                    )
                  : _buildRows(snapshot.data);
            } else if (snapshot.hasError) {
              return Flexible(child: Text("${snapshot.error}"));
            }

            return Container(width: 0, height: 0);
          });
    });
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
            onTap: () => _onBookClick(book),
          );
        });
  }

  _onBookClick(Book book) {
    Navigator.pop(context, book);
  }
}
