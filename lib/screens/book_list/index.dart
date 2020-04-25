import 'package:flutter/material.dart';

import 'package:galpi/components/book_card/main.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/remotes/fetch_books.dart';

class BooksState extends State<Books> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildRows(List<Book> books) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: books.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) {
            return const Divider();
          }

          final index = i ~/ 2;
          return BookCard(book: books[index]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: FutureBuilder<List<Book>>(
          future: fetchBooks(query: '프로그래밍'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildRows(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

class Books extends StatefulWidget {
  @override
  BooksState createState() => BooksState();
}
