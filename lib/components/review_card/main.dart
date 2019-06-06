import 'package:flutter/material.dart';
import 'package:booklog/components/stars_row/index.dart';
import 'package:booklog/models/book.dart';
import 'package:booklog/models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final Book book;
  final GestureTapCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ReviewCard({this.review, this.book, this.onTap, this.onEdit, this.onDelete});

  get bookImage {
    return book.imageUri != ''
        ? Image.network(book.imageUri, width: 100, fit: BoxFit.cover)
        : Container(width: 0, height: 0);
  }

  get bookDescription {
    return Flexible(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Flexible(
                  flex: 0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text(
                      '${book.title}',
                    ),
                    subtitle: Text(
                      '${book.author} | ${book.publisher}',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  )),
              Container(
                child: StarsRow(stars: review.stars),
              ),
            ])));
  }

  get moreIcon {
    return PopupMenuButton(
        icon: Icon(Icons.more_vert),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              {
                onEdit();
                break;
              }
            case 'delete':
              {
                onDelete();
                break;
              }
            default:
              {}
          }
        },
        itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'edit', child: Text('수정')),
              PopupMenuItem(value: 'delete', child: Text('삭제')),
            ]);
  }

  @override
  Widget build(BuildContext context) {
    if (review == null) {
      return Container(width: 0, height: 0);
    }

    return GestureDetector(
      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[bookImage, bookDescription, moreIcon],
        ),
      ),
      onTap: onTap,
    );
  }
}
