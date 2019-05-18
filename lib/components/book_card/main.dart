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
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.network(book.imageUri, width: 100, fit: BoxFit.cover),
              Flexible(
                  child: Column(children: [
                ListTile(
                  title: Text(
                    book.title,
                  ),
                  subtitle: Text(
                    '${book.author} | ${book.publisher}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                )
              ]))
            ]),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
