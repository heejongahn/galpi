import 'package:flutter/material.dart';
import 'package:galpi/models/book.dart';

class BookInfo extends StatelessWidget {
  final Book book;

  BookInfo({
    this.book,
  });

  get bookImage {
    return book.imageUri != ''
        ? Image.network(book.imageUri, height: 150, fit: BoxFit.cover)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return bookImage != null
        ? Stack(
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.fromARGB(15, 0x00, 0x00, 0x00),
                ),
                child: bookImage,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(100, 0x1c, 0x23, 0x2e)),
                  child: buildOverlay(context),
                ),
              )
            ],
          )
        : Container(width: 0, height: 0);
  }

  Widget buildOverlay(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .subtitle
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${book.author} | ${book.publisher}',
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(color: Colors.white),
          )
        ],
      ),
    );
  }
}
