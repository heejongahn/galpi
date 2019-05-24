import 'package:flutter/material.dart';

import 'package:booklog/components/book_card/main.dart';
import 'package:booklog/models/book.dart';
import 'package:booklog/remotes/fetch_books.dart';

class BooksState extends State<Books> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildRows(List<Book> books) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: books.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return BookCard(book: books[index]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('feed'),
      ),
      body: FutureBuilder(
          future: fetchBooks(query: '프로그래밍'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildRows(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class Books extends StatefulWidget {
  @override
  BooksState createState() => new BooksState();
}
