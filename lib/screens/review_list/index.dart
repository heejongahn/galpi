import 'package:flutter/material.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/components/main_drawer/index.dart';
import 'package:galpi/screens/review_list/unread_tab/index.dart';
import 'package:galpi/screens/review_list/review_tab/index.dart';

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

  Future<void> _onOpenNewReview() async {
    await Navigator.of(context).pushNamed('/review/add');
    setState(() {});
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => ReviewsState();
}
