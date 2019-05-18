class Book {
  final String isbn;
  final String title;
  final String author;
  final String linkUri;
  final String imageUri;

  Book({this.author, this.imageUri, this.isbn, this.linkUri, this.title}) {}

  static fromPayload(Map<String, dynamic> json) {
    return Book(
      isbn: json['isbn'],
      title: json['title'],
      author: (json['authors'].cast<String>()).join(", "),
      linkUri: json['uri'],
      imageUri: json['thumbnail'],
    );
  }
}
