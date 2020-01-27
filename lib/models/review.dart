import 'package:galpi/models/book.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

final formatter = DateFormat('yyyy-MM-dd');

enum ReadingStatus {
  hasntStarted,
  reading,
  finishedReading,
}

Map<ReadingStatus, String> readingStatusMap = {
  ReadingStatus.hasntStarted: 'hasntStarted',
  ReadingStatus.reading: 'reading',
  ReadingStatus.finishedReading: 'finishedReading'
};

Map<String, ReadingStatus> readingStatusInverseMap =
    readingStatusMap.map((k, v) => MapEntry(v, k));

class Review {
  String id;
  final int legacyId;
  int stars;
  String title;
  String body;
  ReadingStatus readingStatus;
  DateTime readingStartedAt;
  DateTime readingFinishedAt;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  Review({
    this.id,
    this.legacyId,
    this.stars,
    this.title,
    this.body,
    this.readingStatus = ReadingStatus.hasntStarted,
    this.readingStartedAt,
    this.readingFinishedAt,
    this.createdAt,
    this.lastModifiedAt,
  });

  static Tuple2<Review, Book> fromPayload(Map<String, dynamic> map) {
    final readingStartedAt = map[columnReadingStartedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingStartedAt]);
    final readingFinishedAt = map[columnReadingFinishedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingFinishedAt]);

    final review = Review(
      id: map['id'],
      stars: map['stars'],
      title: map['title'],
      body: map['body'],
      readingStatus: readingStatusInverseMap[map['readingStatus']],
      readingStartedAt: readingStartedAt,
      readingFinishedAt: readingFinishedAt,
      createdAt: DateTime.parse(map['createdAt']),
      lastModifiedAt: DateTime.parse(map['lastModifiedAt']),
    );

    final book = Book.fromPayload(map['book']);

    return Tuple2(review, book);
  }

  Map<String, dynamic> toMap() {
    final now = DateTime.now().toIso8601String();

    var map = <String, dynamic>{
      columnStars: stars,
      columnTitle: title,
      columnBody: body,
      columnReadingStatus: readingStatusMap[readingStatus],
      columnReadingStartedAt: readingStartedAt?.toIso8601String(),
      columnReadingFinishedAt: readingFinishedAt?.toIso8601String(),
      columnLastModifiedAt: now,
    };

    map[columnCreatedAt] =
        createdAt != null ? createdAt.toIso8601String() : now;

    if (id != null) {
      map[columnId] = id;
    }

    return map;
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

  String get displayCreatedDate {
    return formatter.format(this.createdAt);
  }

  // LEGACY
  // 로컬 DB를 없애도 될 때가 되면 지운다

  static final table = 'Review';
  static final columnId = 'id';
  static final columnStars = 'stars';
  static final columnTitle = 'title';
  static final columnBody = 'body';
  static final columnReadingStatus = 'readingStatus';
  static final columnReadingStartedAt = 'readingStartedAt';
  static final columnReadingFinishedAt = 'readingFinishedAt';
  static final columnCreatedAt = 'createdAt';
  static final columnLastModifiedAt = 'lastModifiedAt';
  static final columnBookId = 'bookId';

  static legacy_fromMap(Map<String, dynamic> map) {
    final readingStartedAt = map[columnReadingStartedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingStartedAt]);
    final readingFinishedAt = map[columnReadingFinishedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingFinishedAt]);

    return Review(
      legacyId: map[columnId],
      stars: map[columnStars],
      title: map[columnTitle],
      body: map[columnBody],
      readingStatus: readingStatusInverseMap[map[columnReadingStatus]],
      readingStartedAt: readingStartedAt,
      readingFinishedAt: readingFinishedAt,
      createdAt: DateTime.parse(map[columnCreatedAt]),
      lastModifiedAt: DateTime.parse(map[columnLastModifiedAt]),
    );
  }

  static legacy_fromJoinedMap(Map<String, dynamic> map) {
    final readingStartedAt = map['${table}_${columnReadingStartedAt}'] == null
        ? null
        : DateTime.tryParse(map['${table}_${columnReadingStartedAt}']);
    final readingFinishedAt = map['${table}_${columnReadingFinishedAt}'] == null
        ? null
        : DateTime.tryParse(map['${table}_${columnReadingFinishedAt}']);

    return Review(
      legacyId: map['${table}_${columnId}'],
      stars: map['${table}_${columnStars}'],
      title: map['${table}_${columnTitle}'],
      body: map['${table}_${columnBody}'],
      readingStatus:
          readingStatusInverseMap[map['${table}_${columnReadingStatus}']],
      readingStartedAt: readingStartedAt,
      readingFinishedAt: readingFinishedAt,
      createdAt: DateTime.parse(map['${table}_${columnCreatedAt}']),
      lastModifiedAt: DateTime.parse(map['${table}_${columnLastModifiedAt}']),
    );
  }
}
