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

  static final table = 'Review';
  static final columnId = 'id';
  static final columnStars = 'stars';
  static final columnTitle = 'title';
  static final columnBody = 'body';
  static final columnReadingStartedAt = 'readingStartedAt';
  static final columnReadingFinishedAt = 'readingFinishedAt';
  static final columnCreatedAt = 'createdAt';
  static final columnLastModifiedAt = 'lastModifiedAt';

  Review(
      {this.id,
      this.stars,
      this.title,
      this.body,
      this.readingStartedAt,
      this.readingFinishedAt,
      this.createdAt,
      this.lastModifiedAt});

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
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnStars: stars,
      columnTitle: title,
      columnBody: body,
      columnReadingStartedAt: readingStartedAt,
      columnReadingFinishedAt: readingFinishedAt,
      columnCreatedAt: createdAt,
      columnLastModifiedAt: lastModifiedAt,
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
