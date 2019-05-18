import 'package:flutter/material.dart';

import 'package:booklog/components/book_card/main.dart';
import 'package:booklog/models/book.dart';
import 'package:booklog/remotes/fetch_books.dart';

class BooksState extends State<Books> {
  Widget _buildRows(List<Book> books) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: books.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return BookCard(book: books[index], onTap: _pushSaved);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My booklog'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
          ],
        ),
        body: FutureBuilder(
            future: fetchBooks(query: '프로그래밍'),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildRows(snapshot.data);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return Container(width: 0, height: 0);
            }));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: []),
          );
        },
      ),
    );
  }
}

class Books extends StatefulWidget {
  @override
  BooksState createState() => new BooksState();
}
