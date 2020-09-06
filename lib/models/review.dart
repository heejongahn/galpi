import 'package:json_annotation/json_annotation.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/revision.dart';
import 'package:intl/intl.dart';

part 'review.g.dart';

final formatter = DateFormat('yyyy-MM-dd');

@JsonSerializable()
class Review {
  String id;
  DateTime readingStartedAt;
  DateTime readingFinishedAt;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  bool isPublic;

  Book book;
  Revision activeRevision;

  @deprecated
  final int legacyId;

  @deprecated
  int stars;

  @deprecated
  String title;

  @deprecated
  String body;

  @deprecated
  @JsonKey(defaultValue: ReadingStatus.hasntStarted)
  ReadingStatus readingStatus;

  Review({
    this.id,
    this.readingStartedAt,
    this.readingFinishedAt,
    this.createdAt,
    this.lastModifiedAt,
    this.isPublic = false,
    this.book,
    this.activeRevision,
    /**
     * depreacted
     */
    this.legacyId,
    this.stars,
    this.title,
    this.body,
    this.readingStatus = ReadingStatus.hasntStarted,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

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
