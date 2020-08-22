import 'package:intl/intl.dart';

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

class Revision {
  String id;
  int stars;
  String title;
  String body;
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

  static Revision fromPayload(Map<String, dynamic> map) {
    final createdAt = map['createdAt'] == null
        ? null
        : DateTime.tryParse(map['createdAt'] as String)?.toLocal();
    final lastModifiedAt = map['lastModifiedAt'] == null
        ? null
        : DateTime.tryParse(map['lastModifiedAt'] as String)?.toLocal();

    final revision = Revision(
      id: map['id'] as String,
      stars: map['stars'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
      readingStatus: map['readingStatus'] == null
          ? ReadingStatus.hasntStarted
          : readingStatusInverseMap[map['readingStatus']],
    );

    return revision;
  }

  Map<String, dynamic> toMap() {
    final now = DateTime.now().toIso8601String();

    final map = <String, dynamic>{
      'stars': stars,
      'title': title,
      'body': body,
      'readingStatus': readingStatusMap[readingStatus],
    };

    map['createdAt'] = createdAt != null ? createdAt.toIso8601String() : now;

    if (id != null) {
      map['id'] = id;
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
}
