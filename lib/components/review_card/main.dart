import 'package:flutter/material.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final Book book;
  final GestureTapCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ReviewCard({this.review, this.book, this.onTap, this.onEdit, this.onDelete});

  get bookImage {
    return book.imageUri != ''
        ? Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color.fromARGB(15, 0x00, 0x00, 0x00),
            ),
            child: Image.network(book.imageUri, height: 150, fit: BoxFit.cover))
        : Container(width: 0, height: 0);
  }

  buildBookDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text(review.title, style: Theme.of(context).textTheme.title),
          subtitle: Text([book.title, book.author, book.publisher].join(' | '),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.caption),
        )),
        moreIcon
      ]),
    );
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
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            bookImage,
            buildBookDescription(context),
            // moreIcon
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
