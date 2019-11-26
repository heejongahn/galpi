import 'package:flutter/material.dart';
import 'package:galpi/components/book_info/index.dart';

import 'package:galpi/components/reading_status_chip/index.dart';
import 'package:galpi/components/score_chip/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

typedef Future<void> OnSave(Review review, Book book);

class WriteReviewArgument {
  final OnSave onSave;
  final Book book;
  final Review review;
  final bool isEditing;

  WriteReviewArgument({
    this.book,
    this.review,
    this.onSave,
    this.isEditing = false,
  });
}

class WriteReview extends StatefulWidget {
  final WriteReviewArgument arguments;
  _WriteReviewState createState() => _WriteReviewState();

  WriteReview({@required this.arguments});
}

class _WriteReviewState extends State<WriteReview> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.arguments.isEditing ? '독후감 수정' : '독후감 작성'),
          centerTitle: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              onPressed: _onSave,
            )
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onBlur,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    BookInfo(
                      book: widget.arguments.book,
                    ),
                    getTitleFormField(),
                    getBodyFormField(),
                    getReadingStatusFormFields(),
                    getScoreFormField(),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Padding getTitleFormField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: TextFormField(
        initialValue: widget.arguments.review != null
            ? widget.arguments.review.title
            : null,
        decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: '독후감 제목',
            border: OutlineInputBorder()),
        validator: (value) {
          if (value.isEmpty) {
            return '내용을 입력해주세요.';
          }
        },
        onSaved: (val) => setState(() {
          widget.arguments.review.title = val;
        }),
      ),
    );
  }

  Padding getBodyFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: widget.arguments.review != null
            ? widget.arguments.review.body
            : null,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: '내용',
          border: OutlineInputBorder(),
        ),
        maxLines: 10,
        validator: (value) {
          if (value.isEmpty) {
            return '내용을 입력해주세요.';
          }
        },
        onSaved: (val) => setState(() {
          widget.arguments.review.body = val;
        }),
      ),
    );
  }

  Padding getReadingStatusFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '독서 상태',
            style: Theme.of(context).textTheme.caption,
          ),
          Wrap(
            spacing: 16,
            children: [
              ReadingStatus.hasntStarted,
              ReadingStatus.reading,
              ReadingStatus.finishedReading
            ]
                .map((status) => ReadingStatusChip(
                      readingStatus: status,
                      isSelected:
                          widget.arguments.review.readingStatus == status,
                      onTap: _onReadingStatusBadgeClick,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Padding getScoreFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '평가',
            style: Theme.of(context).textTheme.caption,
          ),
          Wrap(
            spacing: 16,
            children: [1, 2, 3]
                .map((score) => ScoreChip(
                      score: score,
                      isSelected: widget.arguments.review.stars == score,
                      onTap: _onScoreBadgeClick,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  _onScoreBadgeClick(int score) {
    setState(() {
      widget.arguments.review.stars = score;
    });
  }

  _onReadingStatusBadgeClick(ReadingStatus readingStatus) {
    setState(() {
      widget.arguments.review.readingStatus = readingStatus;
    });
  }

  _onSave() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }

    form.save();
    await widget.arguments
        .onSave(widget.arguments.review, widget.arguments.book);
  }

  _onBlur() {
    FocusScope.of(context).unfocus();
  }
}
