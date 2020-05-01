import 'package:flutter/material.dart';
import 'package:galpi/components/avatar/index.dart';
import 'package:galpi/components/book_info/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/models/user.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy-MM-dd');

class ReviewCard extends StatelessWidget {
  final User user;
  final Review review;
  final Book book;
  final GestureTapCallback onTap;

  const ReviewCard({
    this.user,
    this.review,
    this.book,
    this.onTap,
  });

  Widget _buildBookDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 8,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: ListTile(
            contentPadding: const EdgeInsets.all(0),
            leading: Avatar(
              profileImageUrl: user.profileImageUrl,
            ),
            title: Text(
              review.title,
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Text(
              '${user.displayName ?? user.email}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (review == null) {
      return Container(width: 0, height: 0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 24,
      ),
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(32, 33, 36, 0.28),
                blurRadius: 6.0,
                spreadRadius: 0,
                offset: Offset(0, 1),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BookInfo(book: book),
                _buildBookDescription(context),
                // moreIcon
              ],
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
