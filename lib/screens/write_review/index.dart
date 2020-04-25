import 'package:flutter/material.dart';
import 'package:galpi/components/book_info/index.dart';

import 'package:galpi/components/reading_status_chip/index.dart';
import 'package:galpi/components/score_chip/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

typedef OnSave = Future<void> Function(Review review, String bookId);

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
                      getReadingStatusAndIsPublicFormFields(),
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
        decoration: InputDecoration(
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
        onSaved: (val) => setState(() {
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
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: '내용',
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
        onSaved: (val) => setState(() {
          widget.arguments.review.body = val;
        }),
      ),
    );
  }

  Padding getReadingStatusAndIsPublicFormFields() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      '전체 공개 여부',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: Tooltip(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        textStyle: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(color: Colors.white),
                        message: '곧 추가될 피드 및 공유 기능에서\n다른 사람에게 공개할지 여부입니다.',
                        child: Icon(
                          Icons.help_outline,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Switch(
                  onChanged: (isPublic) {
                    setState(() {
                      widget.arguments.review.isPublic = isPublic;
                    });
                  },
                  value: widget.arguments.review.isPublic,
                ),
              ],
            ),
            Column(
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
          ],
        ));
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

  void _onScoreBadgeClick(int score) {
    setState(() {
      widget.arguments.review.stars = score;
    });
  }

  void _onReadingStatusBadgeClick(ReadingStatus readingStatus) {
    setState(() {
      widget.arguments.review.readingStatus = readingStatus;
    });
  }

  Future<void> _onSave() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }

    form.save();
    await widget.arguments.onSave(
      widget.arguments.review,
      widget.arguments.bookId,
    );
  }

  void _onBlur() {
    FocusScope.of(context).unfocus();
  }
}
