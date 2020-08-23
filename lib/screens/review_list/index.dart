import 'package:flutter/material.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/components/main_drawer/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/models/revision.dart';
import 'package:galpi/remotes/create_book.dart';
import 'package:galpi/screens/review_list/review_tab/index.dart';
import 'package:galpi/screens/search_book/index.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/stores/review_repository.dart';
import 'package:galpi/utils/show_error_dialog.dart';
import 'package:galpi/utils/show_material_snackbar.dart';
import 'package:provider/provider.dart';

const PAGE_SIZE = 20;

class ReviewsState extends State<Reviews> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UniqueKey listViewKey = UniqueKey();

  var isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Logo(),
        centerTitle: false,
      ),
      body: ReviewTab(),
      endDrawer: const MainDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onOpenNewReview,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _onOpenNewReview() async {
    /**
     * FIXME: 책만 추가할지 선택
     */
    final arguments = SearchBookArguments(
      onMoveToWriteReview: ({Book book}) async {
        final createdBook = await createBook(book: book);

        Navigator.of(context).pushNamed(
          '/review/write',
          arguments: WriteReviewArgument(
            review: Review(
              stars: 3,
              readingStatus: ReadingStatus.finishedReading,
              book: createdBook,
            ),
            onSave: _onCreateReview,
          ),
        );
      },
      onCreateReviewWithoutRevision: ({Book book}) async {
        final reviewRepository = Provider.of<ReviewRepository>(context);
        final createdBook = await createBook(book: book);
        await reviewRepository.createUnread(book: createdBook);
        showMaterialSnackbar(context, '『${book.title}』을(를) 내 서재에 저장했습니다.');
        Navigator.of(context).pop();
      },
    );

    await Navigator.of(context).pushNamed('/book/search', arguments: arguments);
  }

  Future<void> _onCreateReview(Review review) async {
    final reviewRepository = Provider.of<ReviewRepository>(context);

    try {
      await reviewRepository.create(
        review: review,
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (Route<dynamic> r) => false,
      );
      showMaterialSnackbar(context, '『${review.book.title}』 독후감을 작성했습니다.');
    } catch (e) {
      print(e);
      showErrorDialog(context: context, message: '독후감 작성 중 오류가 발생했습니다.');
    }
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => ReviewsState();
}
