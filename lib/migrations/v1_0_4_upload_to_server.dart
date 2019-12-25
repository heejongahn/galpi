import 'package:galpi/remotes/create_book.dart';
import 'package:galpi/utils/database_helpers.dart';

Future<void> v1_0_4_uploadToServer() async {
  final List<Future> futures = [];
  final queryResult = await DatabaseHelper.instance.queryAllReviews();

  final books = queryResult.item2;

  // TODO: Upload all reviews
  // final reviews = queryResult.item1;
  // futures.addAll(reviews.map((review) => {}));

  futures.addAll(books.map((book) => createBook(book: book)));

  return Future.wait(futures);
}
