import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:booklog/models/review.dart';
import 'package:booklog/models/book.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Book.table} (
        ${Book.columnId} INTEGER PRIMARY KEY,
        ${Book.columnIsbn} TEXT NOT NULL,
        ${Book.columnTitle} TEXT NOT NULL,
        ${Book.columnAuthor} TEXT NOT NULL,
        ${Book.columnPublisher} TEXT NOT NULL,
        ${Book.columnLinkUri} TEXT NOT NULL,
        ${Book.columnImageUri} TEXT NOT NULL 
      );
      ''');

    await db.execute('''
      CREATE TABLE ${Review.table} (
        ${Review.columnId} INTEGER PRIMARY KEY,
        ${Review.columnStars} INTEGER NOT NULL,
        ${Review.columnTitle} TEXT NOT NULL,
        ${Review.columnBody} TEXT NOT NULL,
        ${Review.columnReadingStartedAt} DATETIME,
        ${Review.columnReadingFinishedAt} DATETIME,
        ${Review.columnCreatedAt} DATETIME DEFAULT CURRENT_TIMESTAMP,
        ${Review.columnLastModifiedAt} DATETIME DEFAULT CURRENT_TIMESTAMP,
        ${Review.columnBookId} INTEGER NOT NULL,
        FOREIGN KEY(${Review.columnBookId}) REFERENCES ${Book.table}(${Book.columnId})
      );
      ''');
  }

  Future<int> getOrCreateBook(Book book) async {
    Database db = await database;
    List<Map> maps = await db.query(Book.table,
        where: '${Book.columnIsbn} = ?', whereArgs: [book.isbn]);

    if (maps.length > 0) {
      Book book = Book.fromMap(maps.first);
      return book.id;
    }

    int id = await db.insert(Book.table, book.toMap());
    return id;
  }

  Future<int> insertReview(Review review, Book book) async {
    Database db = await database;
    final bookId = await getOrCreateBook(book);
    int id = await db.insert(Review.table, review.toMap(bookId));
    return id;
  }

  Future<void> deleteReview(int id) async {
    Database db = await database;
    await db
        .delete(Review.table, where: '${Review.columnId} = ?', whereArgs: [id]);
  }

  Future<List<Review>> queryAllReviews() async {
    Database db = await database;
    List<Map> maps = await db.query(Review.table);

    return maps.map((map) => Review.fromMap(map)).cast<Review>().toList();
  }

  Future<Review> queryReview(int id) async {
    Database db = await database;
    List<Map> maps = await db
        .query(Review.table, where: '${Review.columnId} = ?', whereArgs: [id]);

    if (maps.length > 0) {
      return Review.fromMap(maps.first);
    }

    return null;
  }
}
