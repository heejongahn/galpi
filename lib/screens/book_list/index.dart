import 'package:flutter/material.dart';

import 'package:booklog/components/book_card/main.dart';
import 'package:booklog/models/book.dart';
import 'package:booklog/remotes/fetch_books.dart';
import 'package:booklog/screens/add_book/index.dart';

class BooksState extends State<Books> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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
      key: scaffoldKey,
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

            return Center(child: CircularProgressIndicator());
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushSaved,
        child: Icon(Icons.add),
      ),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return AddBook(onSelectBook);
        },
      ),
    );
  }

  onSelectBook(Book book) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(book.title)));
  }
}

class Books extends StatefulWidget {
  @override
  BooksState createState() => new BooksState();
}
