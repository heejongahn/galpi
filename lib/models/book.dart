class Book {
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String linkUri;
  final String imageUri;

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
      linkUri: json['uri'],
      imageUri: json['thumbnail'],
    );
  }
}
