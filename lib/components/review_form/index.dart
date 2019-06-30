import 'package:flutter/material.dart';

import 'package:galpi/components/date_picker_form_field/index.dart';
import 'package:galpi/components/stars_row/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

typedef Future<void> OnSave(Review review, Book book);

class ReviewForm extends StatefulWidget {
  final Book book;
  final OnSave onSave;
  final Review review;

  _ReviewFormState createState() => _ReviewFormState();

  ReviewForm({this.book, this.review, this.onSave}) {}
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                enabled: false,
                initialValue: widget.book.title,
                decoration: InputDecoration(
                    labelText: '제목', border: UnderlineInputBorder()),
                validator: (value) {
                  if (value.isEmpty) {
                    return '제목을 입력해주세요.';
                  }
                },
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 9,
                      child: TextFormField(
                        enabled: false,
                        initialValue: widget.book.author,
                        decoration: InputDecoration(
                            labelText: '작가', border: UnderlineInputBorder()),
                        validator: (value) {
                          if (value.isEmpty) {
                            return '작가를 입력해주세요.';
                          }
                        },
                      ),
                    ),
                    Spacer(flex: 2),
                    Flexible(
                      flex: 9,
                      child: TextFormField(
                          enabled: false,
                          initialValue: widget.book.publisher,
                          decoration: InputDecoration(
                              labelText: '출판사', border: UnderlineInputBorder()),
                          validator: (value) {
                            if (value.isEmpty) {
                              return '출판사를 입력해주세요.';
                            }
                          }),
                    ),
                  ],
                )),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    DatePickerFormField(
                        label: '읽기 시작한 날짜',
                        initialDate: widget.review.readingStartedAt,
                        onSaved: (DateTime date) {
                          widget.review.readingStartedAt = date;
                        }),
                    Spacer(),
                    DatePickerFormField(
                        label: '다 읽은 날짜',
                        initialDate: widget.review.readingFinishedAt,
                        onSaved: (DateTime date) {
                          widget.review.readingFinishedAt = date;
                        }),
                  ],
                )),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: (TextFormField(
                  initialValue:
                      widget.review != null ? widget.review.title : null,
                  decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: '제목',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '내용을 입력해주세요.';
                    }
                  },
                  onSaved: (val) => setState(() {
                        widget.review.title = val;
                      }),
                ))),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: (TextFormField(
                  initialValue:
                      widget.review != null ? widget.review.body : null,
                  maxLines: 5,
                  decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: '내용',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '내용을 입력해주세요.';
                    }
                  },
                  onSaved: (val) => setState(() {
                        widget.review.body = val;
                      }),
                ))),
            StarsRow(
              stars: widget.review.stars,
              size: 24,
              onTapStar: (i) => setState(() {
                    widget.review.stars = i;
                  }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                onPressed: _onSave,
                child: Text('작성'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onSave() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }

    form.save();
    await widget.onSave(widget.review, widget.book);
  }

  _onReadingStartedAtChange(DateTime date) async {
    final form = _formKey.currentState;
  }
}
