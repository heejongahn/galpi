import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

const API_ENDPOINT = "https://dapi.kakao.com/v3/search/book";
const API_KEY = "04180f02a662d58371bb715b54ce4c7b";

class Book {
  final String isbn;
  final String title;
  final String author;
  final String linkUri;
  final String imageUri;

  Book({this.author, this.imageUri, this.isbn, this.linkUri, this.title}) {}

  static fromPayload(Map<String, dynamic> json) {
    return Book(
      isbn: json['isbn'],
      title: json['title'],
      author: (json['authors'].cast<String>()).join(", "),
      linkUri: json['uri'],
      imageUri: json['thumbnail'],
    );
  }
}

Future<List<Book>> fetchBooks({String query}) async {
  final response = await http.get('${API_ENDPOINT}?query=${query}',
      headers: {'Authorization': 'KakaoAK ${API_KEY}'});

  final books = json.decode(response.body)['documents'];

  final bookIterable = books.map((data) => Book.fromPayload(data));
  final bookList = bookIterable.toList().cast<Book>();

  return bookList;
}

class BooksState extends State<Books> {
  final Set<Book> _saved = Set<Book>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildRows(List<Book> books) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: books.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return _buildRow(books[index]);
        });
  }

  Widget _buildRow(Book book) {
    final bool alreadySaved = _saved.contains(book);
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(children: [
          Image.network(book.imageUri, width: width, fit: BoxFit.cover),
          ListTile(
            title: Text(
              book.title,
              style: _biggerFont,
            ),
            subtitle: Text(
              book.author,
              style: TextStyle(fontSize: 14.0),
            ),
          )
        ]),
      ),
      onTap: _pushSaved,
    );
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
            }));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (Book book) {
              return ListTile(
                title: Text(
                  book.title,
                  style: _biggerFont,
                ),
              );
            },
          );

          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
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
