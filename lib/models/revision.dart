import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'revision.g.dart';

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

Map<String, ReadingStatus> readingStatusInverseMap = readingStatusMap.map(
  (k, v) => MapEntry(v, k),
);

@JsonSerializable()
class Revision {
  String id;
  int stars;
  String title;
  String body;
  @JsonKey(defaultValue: ReadingStatus.hasntStarted)
  ReadingStatus readingStatus;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  Revision({
    this.id,
    this.stars,
    this.title,
    this.body,
    this.readingStatus = ReadingStatus.hasntStarted,
    this.createdAt,
    this.lastModifiedAt,
  });

  factory Revision.fromJson(Map<String, dynamic> json) =>
      _$RevisionFromJson(json);

  Map<String, dynamic> toJson() => _$RevisionToJson(this);

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
}
