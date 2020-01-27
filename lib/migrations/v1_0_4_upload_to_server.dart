import 'package:galpi/remotes/create_book.dart';
import 'package:galpi/remotes/review/create.dart';
import 'package:galpi/utils/database_helpers.dart';

Future<void> v1_0_4_uploadToServer() async {
  final List<Future> futures = [];
  final queryResult = await DatabaseHelper.instance.queryAllReviews();

  final size = queryResult.item1.length;

  for (var i = 0; i < size; i++) {
    final review = queryResult.item1[i];
    final book = queryResult.item2[i];

    futures.add(createBook(book: book).then((bookId) {
      createReview(review: review, bookId: bookId);
    }));
  }

  return Future.wait(futures);
}
