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

  static fromKakaoPayload(Map<String, dynamic> json) {
    return Book(
      isbn: json['isbn'],
      title: json['title'],
      author: (json['authors'].cast<String>()).join(", "),
      publisher: json['publisher'],
      linkUri: json['url'],
      imageUri: json['thumbnail'],
    );
  }

  static fromPayload(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      isbn: json['isbn'],
      title: json['title'],
      author: json['author'],
      publisher: json['publisher'],
      linkUri: json['linkUri'],
      imageUri: json['imageUri'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = new Map<String, dynamic>.from({});

    // FIXME
    map['isbn'] = isbn;
    map['title'] = title;
    map['author'] = author;
    map['publisher'] = publisher;
    map['linkUri'] = linkUri;
    map['imageUri'] = imageUri;

    return map;
  }

  // LEGACY
  // 로컬 DB를 없애도 될 때가 되면 지운다

  int _id;

  // legacy
  static final table = 'Book';
  static final columnId = 'id';
  // FIXME
  static final columnIsbn = 'stars';
  static final columnTitle = 'title';
  // FIXME
  static final columnAuthor = 'body';
  static final columnPublisher = 'publisher';
  static final columnLinkUri = 'linkUri';
  static final columnImageUri = 'imageUri';

  static legacy_fromMap(Map<String, dynamic> map) {
    return Book(
      isbn: map[columnIsbn],
      title: map[columnTitle],
      author: map[columnAuthor],
      publisher: map[columnPublisher],
      linkUri: map[columnLinkUri],
      imageUri: map[columnImageUri],
    );
  }

  static legacy_fromJoinedMap(Map<String, dynamic> map) {
    return Book(
      isbn: map['${table}_${columnIsbn}'],
      title: map['${table}_${columnTitle}'],
      author: map['${table}_${columnAuthor}'],
      publisher: map['${table}_${columnPublisher}'],
      linkUri: map['${table}_${columnLinkUri}'],
      imageUri: map['${table}_${columnImageUri}'],
    );
  }

  Map<String, dynamic> legacy_toMap() {
    var map = <String, dynamic>{
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
