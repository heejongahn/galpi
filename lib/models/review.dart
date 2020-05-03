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
  bool isPublic;

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
    this.isPublic = false,
  });

  static Tuple2<Review, Book> fromPayload(Map<String, dynamic> map) {
    final readingStartedAt = map[columnReadingStartedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingStartedAt] as String);

    final readingFinishedAt = map[columnReadingFinishedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingFinishedAt] as String);

    final review = Review(
      id: map['id'] as String,
      stars: map['stars'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      readingStatus: readingStatusInverseMap[map['readingStatus']],
      readingStartedAt: readingStartedAt,
      readingFinishedAt: readingFinishedAt,
      createdAt: DateTime.parse(map['createdAt'] as String).toLocal(),
      lastModifiedAt: DateTime.parse(map['lastModifiedAt'] as String).toLocal(),
      isPublic: map['isPublic'] as bool,
    );

    final book = Book.fromPayload(map['book'] as Map<String, dynamic>);

    return Tuple2(review, book);
  }

  Map<String, dynamic> toMap() {
    final now = DateTime.now().toIso8601String();

    final map = <String, dynamic>{
      'stars': stars,
      'title': title,
      'body': body,
      'readingStatus': readingStatusMap[readingStatus],
      'readingStartedAt': readingStartedAt?.toIso8601String(),
      'readingFinishedAt': readingFinishedAt?.toIso8601String(),
      'isPublic': isPublic
    };

    map[columnCreatedAt] =
        createdAt != null ? createdAt.toIso8601String() : now;

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  String get displayReadingStatus {
    switch (readingStatus) {
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

    return null;
  }

  String get displayCreatedDate {
    return formatter.format(createdAt);
  }

  // LEGACY
  // 로컬 DB를 없애도 될 때가 되면 지운다

  static const table = 'Review';
  static const columnId = 'id';
  static const columnStars = 'stars';
  static const columnTitle = 'title';
  static const columnBody = 'body';
  static const columnReadingStatus = 'readingStatus';
  static const columnReadingStartedAt = 'readingStartedAt';
  static const columnReadingFinishedAt = 'readingFinishedAt';
  static const columnCreatedAt = 'createdAt';
  static const columnLastModifiedAt = 'lastModifiedAt';
  static const columnBookId = 'bookId';

  static Review legacy_fromMap(Map<String, dynamic> map) {
    final readingStartedAt = map[columnReadingStartedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingStartedAt] as String);
    final readingFinishedAt = map[columnReadingFinishedAt] == null
        ? null
        : DateTime.tryParse(map[columnReadingFinishedAt] as String);

    return Review(
      legacyId: map[columnId] as int,
      stars: map[columnStars] as int,
      title: map[columnTitle] as String,
      body: map[columnBody] as String,
      readingStatus: readingStatusInverseMap[map[columnReadingStatus]],
      readingStartedAt: readingStartedAt,
      readingFinishedAt: readingFinishedAt,
      createdAt: DateTime.parse(map[columnCreatedAt] as String).toLocal(),
      lastModifiedAt:
          DateTime.parse(map[columnLastModifiedAt] as String).toLocal(),
    );
  }

  static Review legacy_fromJoinedMap(Map<String, dynamic> map) {
    final readingStartedAt = map['${table}_${columnReadingStartedAt}'] == null
        ? null
        : DateTime.tryParse(
            map['${table}_${columnReadingStartedAt}'] as String);
    final readingFinishedAt = map['${table}_${columnReadingFinishedAt}'] == null
        ? null
        : DateTime.tryParse(
            map['${table}_${columnReadingFinishedAt}'] as String);

    return Review(
      legacyId: map['${table}_${columnId}'] as int,
      stars: map['${table}_${columnStars}'] as int,
      title: map['${table}_${columnTitle}'] as String,
      body: map['${table}_${columnBody}'] as String,
      readingStatus:
          readingStatusInverseMap[map['${table}_${columnReadingStatus}']],
      readingStartedAt: readingStartedAt,
      readingFinishedAt: readingFinishedAt,
      createdAt: DateTime.parse(
        map['${table}_${columnCreatedAt}'] as String,
      ).toLocal(),
      lastModifiedAt: DateTime.parse(
        map['${table}_${columnLastModifiedAt}'] as String,
      ).toLocal(),
    );
  }
}
