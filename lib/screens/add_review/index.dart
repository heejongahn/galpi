import 'package:flutter/material.dart';

import 'package:booklog/components/book_card/main.dart';
import 'package:booklog/models/book.dart';
import 'package:booklog/models/review.dart';
import 'package:booklog/remotes/fetch_books.dart';
import 'package:booklog/utils/database_helpers.dart';

class AddReview extends StatefulWidget {
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  FocusNode _focusNode = new FocusNode();
  Book selectedBook;
  Review review;
  FutureBuilder<List<Book>> searchResultBuilder;

  Widget get searchView {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: TextField(
          focusNode: this._focusNode,
          onSubmitted: this._searchBooks,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
              labelText: '책 제목',
              prefixIcon: this._focusNode.hasFocus
                  ? IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        this._focusNode.unfocus();
                      })
                  : Icon(Icons.search),
              border: OutlineInputBorder()),
        ),
      ),
      Expanded(
          child: searchResultBuilder == null
              ? Container(
                  alignment: Alignment.center, child: Text('검색 결과가 없습니다.'))
              : searchResultBuilder)
    ]);
  }

  Widget get writeView {
    return Form(
        child: Column(
      children: <Widget>[
        TextFormField(
          decoration:
              InputDecoration(labelText: '제목', border: OutlineInputBorder()),
          validator: (value) {
            if (value.isEmpty) {
              return '제목을 입력해주세요.';
            }
          },
        ),
        TextFormField(
            decoration:
                InputDecoration(labelText: '제목', border: OutlineInputBorder()),
            validator: (value) {
              if (value.isEmpty) {
                return '내용을 입력해주세요.';
              }
            }),
      ],
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('새 리뷰'),
        ),
        body: selectedBook != null ? writeView : searchView);
  }

  _searchBooks(String query) async {
    setState(() {
      this.searchResultBuilder = FutureBuilder(
          future: fetchBooks(query: query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data == null
                  ? Container(
                      width: 0,
                      height: 0,
                    )
                  : _buildRows(snapshot.data);
            } else if (snapshot.hasError) {
              return Flexible(child: Text("${snapshot.error}"));
            }

            return Container(width: 0, height: 0);
          });
    });
  }

  Widget _buildRows(List<Book> books) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16.0),
        itemCount: books.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          final book = books[index];
          return BookCard(
            book: book,
            onTap: () => _onBookClick(book),
          );
        });
  }

  _onBookClick(Book book) {
    setState(() {
      selectedBook = book;
    });
  }

  _onCreate() async {
    await DatabaseHelper.instance.insertReview(review);
    Navigator.of(context).pop();
  }
}
