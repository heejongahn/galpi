// import 'package:booklog/models/book.dart';

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
  final DateTime readingStartedAt;
  final DateTime readingFinishedAt;
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
    return Review(
        id: map[columnId],
        stars: map[columnStars],
        title: map[columnTitle],
        body: map[columnBody],
        readingStartedAt: map[columnReadingStartedAt],
        readingFinishedAt: map[columnReadingFinishedAt],
        createdAt: map[columnCreatedAt],
        lastModifiedAt: map[columnLastModifiedAt],
        bookId: map[columnBookId]);
  }

  static fromJoinedMap(Map<String, dynamic> map) {
    return Review(
        id: map['${table}_${columnId}'],
        stars: map['${table}_${columnStars}'],
        title: map['${table}_${columnTitle}'],
        body: map['${table}_${columnBody}'],
        readingStartedAt: map['${table}_${columnReadingStartedAt}'],
        readingFinishedAt: map['${table}_${columnReadingFinishedAt}'],
        createdAt: map['${table}_${columnCreatedAt}'],
        lastModifiedAt: map['${table}_${columnLastModifiedAt}'],
        bookId: map['${table}_${columnBookId}']);
  }

  Map<String, dynamic> toMap(int bookId) {
    var map = <String, dynamic>{
      columnStars: stars,
      columnTitle: title,
      columnBody: body,
      columnReadingStartedAt: readingStartedAt,
      columnReadingFinishedAt: readingFinishedAt,
      columnCreatedAt: createdAt,
      columnLastModifiedAt: lastModifiedAt,
      columnBookId: bookId
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  ReadingStatus get readingStatus {
    if (readingStartedAt == null) {
      return ReadingStatus.hasntStarted;
    }

    if (readingFinishedAt == null) {
      return ReadingStatus.reading;
    }

    return ReadingStatus.finishedReading;
  }
}
