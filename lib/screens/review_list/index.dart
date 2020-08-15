import 'package:flutter/material.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/components/main_drawer/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/remotes/create_book.dart';
import 'package:galpi/screens/review_list/unread_tab/index.dart';
import 'package:galpi/screens/review_list/review_tab/index.dart';
import 'package:galpi/screens/search_book/index.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/stores/review_repository.dart';
import 'package:galpi/utils/show_error_dialog.dart';
import 'package:provider/provider.dart';

const PAGE_SIZE = 20;

class ReviewsState extends State<Reviews> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Tab> _tabs = <Tab>[
    const Tab(
      child: Text(
        '읽기 전',
      ),
    ),
    const Tab(
      child: Text(
        '읽음',
      ),
    ),
  ];

  TabController _tabController;

  UniqueKey listViewKey = UniqueKey();

  var isInitialized = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: _tabs.length,
    );

    _tabController.addListener(
      () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Logo(),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black54,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UnreadTab(),
          ReviewTab(),
        ],
      ),
      endDrawer: const MainDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onOpenNewReview,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _onOpenAddUnreadReview() async {
    final arguments = SearchBookArguments(onSelect: ({Book book}) async {
      return;
    });

    await Navigator.of(context).pushNamed('/book/search', arguments: arguments);
  }

  Future<void> _onOpenNewReview() async {
    final arguments = SearchBookArguments(onSelect: ({Book book}) async {
      final bookId = await createBook(book: book);

      Navigator.of(context).pushNamed(
        '/review/write',
        arguments: WriteReviewArgument(
          review: Review(
            stars: 3,
            readingStatus: ReadingStatus.finishedReading,
          ),
          book: book,
          bookId: bookId,
          onSave: _onCreateReview,
        ),
      );
      return;
    });

    await Navigator.of(context).pushNamed('/book/search', arguments: arguments);
  }

  Future<void> _onCreateReview(Review review, {String bookId}) async {
    final reviewRepository = Provider.of<ReviewRepository>(context);

    try {
      await reviewRepository.create(review: review, bookId: bookId);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (Route<dynamic> r) => false,
      );
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
