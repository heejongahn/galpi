import 'package:flutter/material.dart';

final books = [
  new Book(
      title: "함께 자라기",
      author: "김창준",
      isbn: "9788966262335",
      linkUri:
          "https://m.search.daum.net/search?w=bookpage&bookId=4833808&q=%ED%95%A8%EA%BB%98%20%EC%9E%90%EB%9D%BC%EA%B8%B0",
      imageUri:
          "https://search1.kakaocdn.net/thumb/C216x312.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F4833808%3Fmoddttm=201902032300"),
  new Book(
      title: "플라이룸",
      author: "김우재",
      isbn: "9788934984368",
      linkUri:
          "https://m.search.daum.net/search?w=bookpage&bookId=4836833&tab=introduction&DA=LB0&q=%ED%94%8C%EB%9D%BC%EC%9D%B4%EB%A3%B8",
      imageUri:
          "https://search1.kakaocdn.net/thumb/C216x312.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F4836833%3Fmoddttm=201902032302")
];

class Book {
  final String isbn;
  final String title;
  final String author;
  final String linkUri;
  final String imageUri;

  Book({this.author, this.imageUri, this.isbn, this.linkUri, this.title}) {}
}

class BooksState extends State<Books> {
  List<Book> _books = books;
  final Set<Book> _saved = Set<Book>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildRows() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _books.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return _buildRow(_books[index]);
        });
  }

  Widget _buildRow(Book book) {
    final bool alreadySaved = _saved.contains(book);
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(children: [
          Image.network(book.imageUri, width: width, fit: BoxFit.cover),
          ListTile(
            title: Text(
              book.title,
              style: _biggerFont,
            ),
            subtitle: Text(
              book.author,
              style: TextStyle(fontSize: 14.0),
            ),
          )
        ]),
      ),
      onTap: _pushSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My booklog'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildRows(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (Book book) {
              return ListTile(
                title: Text(
                  book.title,
                  style: _biggerFont,
                ),
              );
            },
          );

          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}

class Books extends StatefulWidget {
  @override
  BooksState createState() => new BooksState();
}
