import 'package:flutter/material.dart';
import 'package:galpi/components/book_info/index.dart';
import 'package:galpi/components/reading_status_badge/index.dart';
import 'package:galpi/components/score_badge/index.dart';

import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/models/revision.dart';
import 'package:galpi/screens/review_preview/index.dart';

typedef OnSave = Future<void> Function(Review review, {String bookId});

class WriteReviewArgument {
  final OnSave onSave;
  final Book book;
  final String bookId;
  final Review review;
  final bool isEditing;

  WriteReviewArgument({
    this.book,
    this.bookId,
    this.review,
    this.onSave,
    this.isEditing = false,
  });
}

class WriteReview extends StatefulWidget {
  final WriteReviewArgument arguments;

  const WriteReview({@required this.arguments});

  @override
  _WriteReviewState createState() => _WriteReviewState();
}

class _WriteReviewState extends State<WriteReview> {
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arguments.isEditing ? '독후감 수정' : '독후감 작성'),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: _onOpenPreviewDialog,
          ),
          isSaving
              ? Center(
                  child: Container(
                    width: 48,
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.done),
                  onPressed: _onSave,
                )
        ],
        // bottom: isSaving
        //     ? const PreferredSize(
        //         preferredSize: Size(double.infinity, 0),
        //         child: LinearProgressIndicator(
        //           backgroundColor: Colors.white,
        //         ),
        //       )
        //     : null,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onBlur,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BookInfo(
                  book: widget.arguments.book,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTitleFormField(),
                      getBodyFormField(),
                      getReadingStatusField(),
                      getScoreFormField(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      // ),
    );
  }

  Padding getTitleFormField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: TextFormField(
        initialValue: widget.arguments.review != null
            ? widget.arguments.review.title
            : null,
        decoration: const InputDecoration(
          alignLabelWithHint: true,
          labelText: '제목',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return '내용을 입력해주세요.';
          }

          return null;
        },
        onChanged: (val) => setState(() {
          widget.arguments.review.title = val;
        }),
      ),
    );
  }

  Padding getBodyFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: TextFormField(
        initialValue: widget.arguments.review != null
            ? widget.arguments.review.body
            : null,
        decoration: const InputDecoration(
          alignLabelWithHint: true,
          labelText: '내용',
          helperText: '마크다운(Markdown) 문법을 지원합니다.',
          helperStyle: TextStyle(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        maxLines: 10,
        validator: (value) {
          if (value.isEmpty) {
            return '내용을 입력해주세요.';
          }

          return null;
        },
        onChanged: (val) => setState(() {
          widget.arguments.review.body = val;
        }),
      ),
    );
  }

  Padding getReadingStatusField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '독서 상태',
            style: Theme.of(context).textTheme.caption,
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 16,
              children: [
                ReadingStatus.finishedReading,
                ReadingStatus.reading,
              ]
                  .map(
                    (status) => GestureDetector(
                      child: Opacity(
                        opacity: widget.arguments.review.readingStatus == status
                            ? 1
                            : 0.6,
                        child: ReadingStatusBadge(
                          readingStatus: status,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          widget.arguments.review.readingStatus = status;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
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
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 12,
              children: [3, 2, 1]
                  .map(
                    (score) => GestureDetector(
                      child: Opacity(
                        opacity:
                            widget.arguments.review.stars == score ? 1 : 0.6,
                        child: ScoreBadge(
                          score: score,
                        ),
                      ),
                      onTap: () {
                        setState(
                          () {
                            widget.arguments.review.stars = score;
                          },
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }

    form.save();
    setState(() {
      isSaving = true;
    });

    try {
      await widget.arguments.onSave(
        widget.arguments.review,
        bookId: widget.arguments.bookId,
      );
    } finally {
      if (mounted)
        setState(() {
          isSaving = false;
        });
    }
  }

  void _onOpenPreviewDialog() {
    final args =
        ReviewPreviewArguments(widget.arguments.review, widget.arguments.book);
    Navigator.of(context).pushNamed(
      '/review/preview',
      arguments: args,
    );
  }

  void _onBlur() {
    FocusScope.of(context).unfocus();
  }
}
