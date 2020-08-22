import 'package:flutter/material.dart';
import 'package:galpi/models/book.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy년 M월 d일');
final empytyImage = Container(
    alignment: Alignment.center,
    width: 100,
    height: 140,
    color: Colors.white,
    child: const Text(
      '이미지 정보 없음',
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey,
      ),
    ));

class BookCard extends StatelessWidget {
  final Book book;
  final Widget adornment;
  final GestureTapCallback onTap;

  const BookCard({this.book, this.onTap, this.adornment});

  @override
  Widget build(BuildContext context) {
    if (book == null) {
      return Container(width: 0, height: 0);
    }

    final bookImage = book.imageUri != null && book.imageUri != ''
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26, width: 0.5),
              boxShadow: [
                const BoxShadow(
                  blurRadius: 8,
                  offset: Offset(0, 12),
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                )
              ],
            ),
            child: Image.network(
              book.imageUri,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return empytyImage;
              },
            ),
          )
        : empytyImage;

    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bookImage,
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Title(book: book, textTheme: textTheme),
                      _Author(book: book, textTheme: textTheme),
                      _Publisher(book: book, textTheme: textTheme),
                      if (adornment != null) adornment
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    Key key,
    @required this.book,
    @required this.textTheme,
  }) : super(key: key);

  final Book book;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      book.title,
      maxLines: 2,
      style: textTheme.subtitle1.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Publisher extends StatelessWidget {
  const _Publisher({
    Key key,
    @required this.book,
    @required this.textTheme,
  }) : super(key: key);

  final Book book;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      book.publisher,
      style: textTheme.subtitle2.copyWith(
        color: Colors.grey,
        fontSize: 14.0,
        height: 1.4,
      ),
    );
  }
}

class _Author extends StatelessWidget {
  const _Author({
    Key key,
    @required this.book,
    @required this.textTheme,
  }) : super(key: key);

  final Book book;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      book.author,
      style: textTheme.subtitle2.copyWith(
        color: Colors.grey,
        fontSize: 14.0,
        height: 1.4,
      ),
    );
  }
}
