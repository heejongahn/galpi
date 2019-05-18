import 'package:flutter/material.dart';

import 'package:booklog/components/book_card/main.dart';
import 'package:booklog/models/book.dart';
import 'package:booklog/remotes/fetch_books.dart';

typedef void OnSelectBook(Book book);

class AddBook extends StatefulWidget {
  final OnSelectBook onSelectBook;

  AddBook(this.onSelectBook);

  _AddBookState createState() => _AddBookState(this.onSelectBook);
}

class _AddBookState extends State<AddBook> {
  String query = '파이썬';
  Book selectedBook;
  FutureBuilder<List<Book>> searchResultBuilder;
  OnSelectBook onSelectBook;

  _AddBookState(this.onSelectBook);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('책 추가'),
        ),
        body: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onSubmitted: _searchBooks,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
            ),
          ),
          Expanded(
              child: searchResultBuilder == null
                  ? Container(child: Text('검색어 입력'))
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
    onSelectBook(book);
    Navigator.of(context).pop();
  }
}
