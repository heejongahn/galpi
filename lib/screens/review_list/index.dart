import 'package:flutter/material.dart';
import 'package:galpi/screens/phone_auth/index.dart';
import 'package:package_info/package_info.dart';
import 'package:tuple/tuple.dart';

import 'package:galpi/screens/add_review/index.dart';
import 'package:galpi/screens/review_detail/index.dart';
import 'package:galpi/components/review_card/main.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/utils/database_helpers.dart';

class ReviewsState extends State<Reviews> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildEmptyScreen() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '작성한 독후감이 없습니다.\n시작하기 위해 첫 독후감을 작성해보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildRows(List<Review> reviews, List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemCount: reviews.length,
      itemBuilder: (context, i) {
        final review = reviews[i];
        final book = books[i];

        return Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          child: ReviewCard(
            review: reviews[i],
            book: books[i],
            onTap: () => _onOpenReviewDetail(review, book),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'galpi',
          style: TextStyle(fontFamily: 'Abril-Fatface'),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: FutureBuilder<Tuple2<List<Review>, List<Book>>>(
            future: DatabaseHelper.instance.queryAllReviews(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final reviews = snapshot.data.item1;
                final books = snapshot.data.item2;
                return reviews.length > 0
                    ? _buildRows(reviews, books)
                    : _buildEmptyScreen();
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return Center(child: CircularProgressIndicator());
            }),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: ListTile(
                title: Text(
                  '프로필 없음',
                ),
                subtitle: Text('로그인하세요'),
              ),
            ),
            buildAboutListTile(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('로그인'),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return PhoneAuth();
                }));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onOpenNewReview,
        child: Icon(Icons.add),
      ),
    );
  }

  FutureBuilder<PackageInfo> buildAboutListTile() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'galpi',
            applicationVersion: snapshot.data.version,
          );
        }

        return AboutListTile(
          icon: Icon(Icons.info_outline),
          applicationName: 'galpi',
        );
      },
    );
  }

  void _onOpenReviewDetail(Review review, Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewDetail(review: review, book: book),
      ),
    );
  }

  void _onOpenNewReview() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddReview()));

    setState(() {});
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => ReviewsState();
}
