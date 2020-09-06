import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

@JsonSerializable()
class Book {
  final String id;
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String linkUri;
  final String imageUri;

  Book(
      {this.id,
      this.author,
      this.imageUri,
      this.isbn,
      this.publisher,
      this.linkUri,
      this.title});

  static Book fromKakaoPayload(Map<String, dynamic> json) {
    final List<String> authors =
        List<String>.from(json['authors'] as List<dynamic>);
    final String author = authors.join(", ");

    return Book(
      isbn: json['isbn'] as String,
      title: json['title'] as String,
      author: author,
      publisher: json['publisher'] as String,
      linkUri: json['url'] as String,
      imageUri: json['thumbnail'] as String,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);

  // LEGACY
  // 로컬 DB를 없애도 될 때가 되면 지운다

  // legacy
  static const table = 'Book';
  static const columnId = 'id';
  // FIXME
  static const columnIsbn = 'stars';
  static const columnTitle = 'title';
  // FIXME
  static const columnAuthor = 'body';
  static const columnPublisher = 'publisher';
  static const columnLinkUri = 'linkUri';
  static const columnImageUri = 'imageUri';

  static Book legacy_fromMap(Map<String, dynamic> map) {
    return Book(
      isbn: map[columnIsbn] as String,
      title: map[columnTitle] as String,
      author: map[columnAuthor] as String,
      publisher: map[columnPublisher] as String,
      linkUri: map[columnLinkUri] as String,
      imageUri: map[columnImageUri] as String,
    );
  }

  static Book legacy_fromJoinedMap(Map<String, dynamic> map) {
    return Book(
      isbn: map['${table}_${columnIsbn}'] as String,
      title: map['${table}_${columnTitle}'] as String,
      author: map['${table}_${columnAuthor}'] as String,
      publisher: map['${table}_${columnPublisher}'] as String,
      linkUri: map['${table}_${columnLinkUri}'] as String,
      imageUri: map['${table}_${columnImageUri}'] as String,
    );
  }

  Map<String, dynamic> legacy_toMap() {
    final map = <String, dynamic>{
      columnIsbn: isbn,
      columnTitle: title,
      columnAuthor: author,
      columnPublisher: publisher,
      columnLinkUri: linkUri,
      columnImageUri: imageUri,
    };

    return map;
  }
}
