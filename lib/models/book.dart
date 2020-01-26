class Book {
  // FIXME: 삭제하고 서버에서 주는 id로 대체
  int _id;
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String linkUri;
  final String imageUri;

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

  Book(
      {this.author,
      this.imageUri,
      this.isbn,
      this.publisher,
      this.linkUri,
      this.title});

  static fromPayload(Map<String, dynamic> json) {
    return Book(
      isbn: json['isbn'],
      title: json['title'],
      author: (json['authors'].cast<String>()).join(", "),
      publisher: json['publisher'],
      linkUri: json['url'],
      imageUri: json['thumbnail'],
    );
  }

  static fromMap(Map<String, dynamic> map) {
    return Book(
      isbn: map[columnIsbn],
      title: map[columnTitle],
      author: map[columnAuthor],
      publisher: map[columnPublisher],
      linkUri: map[columnLinkUri],
      imageUri: map[columnImageUri],
    );
  }

  static fromJoinedMap(Map<String, dynamic> map) {
    return Book(
      isbn: map['${table}_${columnIsbn}'],
      title: map['${table}_${columnTitle}'],
      author: map['${table}_${columnAuthor}'],
      publisher: map['${table}_${columnPublisher}'],
      linkUri: map['${table}_${columnLinkUri}'],
      imageUri: map['${table}_${columnImageUri}'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = this.toLegacyMap();
    // FIXME
    map['isbn'] = map[columnIsbn];
    map['author'] = map[columnAuthor];

    return map;
  }

  Map<String, dynamic> toLegacyMap() {
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
