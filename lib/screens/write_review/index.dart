import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galpi/components/book_info/index.dart';

import 'package:galpi/components/date_picker_form_field/index.dart';
import 'package:galpi/components/score_chip/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

typedef Future<void> OnSave(Review review, Book book);

class WriteReview extends StatefulWidget {
  final OnSave onSave;
  final Book book;
  final Review review;
  final bool isEditing;

  _WriteReviewState createState() => _WriteReviewState();

  WriteReview({this.book, this.review, this.onSave, this.isEditing = false}) {}
}

class _WriteReviewState extends State<WriteReview> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? '독후감 수정' : '독후감 작성'),
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
                      book: widget.book,
                    ),
                    getTitleFormField(),
                    getBodyFormField(),
                    getDateFormFields(),
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
        initialValue: widget.review != null ? widget.review.title : null,
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
          widget.review.title = val;
        }),
      ),
    );
  }

  Padding getBodyFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: widget.review != null ? widget.review.body : null,
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
          widget.review.body = val;
        }),
      ),
    );
  }

  Padding getDateFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: <Widget>[
          DatePickerFormField(
            label: '읽기 시작한 날짜',
            initialDate: widget.review.readingStartedAt,
            onSaved: (DateTime date) {
              widget.review.readingStartedAt = date;
            },
          ),
          Spacer(),
          DatePickerFormField(
            label: '다 읽은 날짜',
            initialDate: widget.review.readingFinishedAt,
            onSaved: (DateTime date) {
              widget.review.readingFinishedAt = date;
            },
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
                      isSelected: widget.review.stars == score,
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
      widget.review.stars = score;
    });
  }

  _onSave() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }

    form.save();
    await widget.onSave(widget.review, widget.book);
  }

  _onBlur() {
    FocusScope.of(context).unfocus();
  }
}
