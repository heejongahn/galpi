import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

import 'package:galpi/components/infinite_scroll_list_view/index.dart';
import 'package:galpi/components/book_card/main.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/remotes/fetch_books.dart';

typedef OnSelectBook = Future<void> Function({Book book});

class SearchView extends StatefulWidget {
  final OnSelectBook onMoveToWriteReview;
  final OnSelectBook onCreateReviewWithoutRevision;

  const SearchView({
    this.onMoveToWriteReview,
    this.onCreateReviewWithoutRevision,
  });

  @override
  _SearchViewState createState() => _SearchViewState();
}

const PAGE_SIZE = 20;

class _SearchViewState extends State<SearchView> {
  final FocusNode _focusNode = FocusNode();
  List<Book> books = [];

  String query = '';
  final StreamController<String> _queryStreamController = StreamController();

  Observable<String> queryObservable;

  _SearchViewState() {
    Observable(_queryStreamController.stream)
        .distinct()
        .debounceTime(const Duration(milliseconds: 1000))
        .listen(_onQueryChange);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.black26, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                offset: Offset(0, 4),
                color: Color.fromRGBO(0, 0, 0, 0.05),
              )
            ],
          ),
          child: TextField(
            autofocus: true,
            focusNode: _focusNode,
            onChanged: (v) {
              _queryStreamController.sink.add(v);
            },
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: '검색어',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(child: _buildContent()),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _queryStreamController.close();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onOnFocusNodeEvent);
  }

  void _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  void _onQueryChange(String newQuery) {
    setState(() {
      query = newQuery;
      books = [];
    });
  }

  Widget _buildContent() {
    if (query == '') {
      return _buildPlaceholder();
    }

    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InfiniteScrollListView(
        key: Key(query),
        data: books,
        fetchMore: _fetchMore,
        itemBuilder: (Book book, {int index}) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: BookCard(
              book: book,
              onTap: () => _onTapBookCard(book: book),
            ),
          );
        },
        emptyWidget: _buildPlaceholder(),
      ),
    );
  }

  void _onTapBookCard({
    Book book,
  }) {
    const maxTitleLength = 20;
    final truncatedTitle = book.title.length > maxTitleLength
        ? '${book.title.substring(0, maxTitleLength)}…'
        : book.title;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text('『${truncatedTitle}』'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onMoveToWriteReview(book: book);
              },
              child: const Text('독후감 남기기'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onCreateReviewWithoutRevision(book: book);
              },
              child: const Text('독후감 없이 책만 먼저 추가하기'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _fetchMore() async {
    final fetchedBooks = await fetchBooks(
      query: query,
      page: (books.length ~/ PAGE_SIZE) + 1,
      size: PAGE_SIZE,
    );

    if (!mounted) {
      return false;
    }

    setState(() {
      books = books + fetchedBooks;
    });

    return fetchedBooks.length >= PAGE_SIZE;
  }

  Widget _buildPlaceholder() {
    return Container(
      alignment: Alignment.center,
      child: query == ''
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('제목, 저자, 출판사 등의 키워드로 검색할 수 있습니다.'),
            ])
          : const Text('검색 결과가 없습니다.'),
    );
  }
}
