// import 'package:galpi/models/book.dart';
import 'dart:developer';

enum ReadingStatus {
  hasntStarted,
  reading,
  finishedReading,
}

class Review {
  final int id;
  int stars;
  String title;
  String body;
  DateTime readingStartedAt;
  DateTime readingFinishedAt;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final int bookId;

  static final table = 'Review';
  static final columnId = 'id';
  static final columnStars = 'stars';
  static final columnTitle = 'title';
  static final columnBody = 'body';
  static final columnReadingStartedAt = 'readingStartedAt';
  static final columnReadingFinishedAt = 'readingFinishedAt';
  static final columnCreatedAt = 'createdAt';
  static final columnLastModifiedAt = 'lastModifiedAt';
  static final columnBookId = 'bookId';

  Review(
      {this.id,
      this.stars,
      this.title,
      this.body,
      this.readingStartedAt,
      this.readingFinishedAt,
      this.createdAt,
      this.lastModifiedAt,
      this.bookId});

  static fromMap(Map<String, dynamic> map) {
    final readingStartedAt = map[columnReadingStartedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingStartedAt]);
    final readingFinishedAt = map[columnReadingFinishedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingFinishedAt]);

    return Review(
        id: map[columnId],
        stars: map[columnStars],
        title: map[columnTitle],
        body: map[columnBody],
        readingStartedAt: readingStartedAt,
        readingFinishedAt: readingFinishedAt,
        createdAt: DateTime.parse(map[columnCreatedAt]),
        lastModifiedAt: DateTime.parse(map[columnLastModifiedAt]),
        bookId: map[columnBookId]);
  }

  static fromJoinedMap(Map<String, dynamic> map) {
    final readingStartedAt = map['${table}_${columnReadingStartedAt}'] == null
        ? null
        : DateTime.tryParse(map['${table}_${columnReadingStartedAt}']);
    final readingFinishedAt = map['${table}_${columnReadingFinishedAt}'] == null
        ? null
        : DateTime.tryParse(map['${table}_${columnReadingFinishedAt}']);

    return Review(
        id: map['${table}_${columnId}'],
        stars: map['${table}_${columnStars}'],
        title: map['${table}_${columnTitle}'],
        body: map['${table}_${columnBody}'],
        readingStartedAt: readingStartedAt,
        readingFinishedAt: readingFinishedAt,
        createdAt: DateTime.parse(map['${table}_${columnCreatedAt}']),
        lastModifiedAt: DateTime.parse(map['${table}_${columnLastModifiedAt}']),
        bookId: map['${table}_${columnBookId}']);
  }

  Map<String, dynamic> toMap(int bookId) {
    final now = DateTime.now().toIso8601String();

    var map = <String, dynamic>{
      columnStars: stars,
      columnTitle: title,
      columnBody: body,
      columnReadingStartedAt: readingStartedAt?.toIso8601String(),
      columnReadingFinishedAt: readingFinishedAt?.toIso8601String(),
      columnLastModifiedAt: now,
      columnBookId: bookId
    };

    map[columnCreatedAt] =
        createdAt != null ? createdAt.toIso8601String() : now;

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  ReadingStatus get readingStatus {
    final now = DateTime.now();

    if (readingFinishedAt != null && now.isAfter(readingFinishedAt)) {
      return ReadingStatus.finishedReading;
    }

    if (readingStartedAt != null && now.isAfter(readingStartedAt)) {
      return ReadingStatus.reading;
    }

    return ReadingStatus.hasntStarted;
  }

  String get displayReadingStatus {
    switch (this.readingStatus) {
      case ReadingStatus.reading:
        {
          return '읽는 중';
        }
      case ReadingStatus.hasntStarted:
        {
          return '읽기 전';
        }
      case ReadingStatus.finishedReading:
        {
          return '읽음';
        }
    }
  }
}
