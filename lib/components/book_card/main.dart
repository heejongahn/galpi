import 'package:flutter/material.dart';
import 'package:booklog/models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final GestureTapCallback onTap;

  BookCard({this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (book == null) {
      return Container(width: 0, height: 0);
    }

    return GestureDetector(
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 16, bottom: 16, left: 8, right: 8),
          child: Row(children: [
            Image.network(book.imageUri, width: 100, fit: BoxFit.cover),
            Flexible(
                child: Column(children: [
              ListTile(
                title: Text(
                  book.title,
                ),
                subtitle: Text(
                  book.author,
                  style: TextStyle(fontSize: 14.0),
                ),
              )
            ]))
          ]),
        ),
      ),
      onTap: onTap,
    );
  }
}
