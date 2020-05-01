import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

import 'package:galpi/components/infinite_scroll_list_view/index.dart';
import 'package:galpi/components/book_card/main.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/remotes/fetch_books.dart';

typedef OnSelectBook = void Function(Book book);

class SearchView extends StatefulWidget {
  final OnSelectBook onSelectBook;

  const SearchView({this.onSelectBook});

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
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: TextField(
          autofocus: true,
          focusNode: _focusNode,
          onChanged: (v) {
            _queryStreamController.sink.add(v);
          },
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            labelText: '제목, 저자, 출판사',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Expanded(child: _buildContent()),
    ]);
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
    });
  }

  Widget _buildContent() {
    if (query == '') {
      return _buildPlaceholder();
    }

    return InfiniteScrollListView(
      data: books,
      fetchMore: _fetchMore,
      itemBuilder: (Book book, {int index}) {
        return BookCard(
          book: book,
          onTap: () => widget.onSelectBook(book),
        );
      },
      emptyWidget: _buildPlaceholder(),
    );
  }

  Future<bool> _fetchMore() async {
    final fetchedBooks = await fetchBooks(
      query: query,
      page: (books.length ~/ PAGE_SIZE) + 1,
      size: PAGE_SIZE,
    );

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
              const Text('독후감을 작성할 책을 찾아보세요.'),
              const Text('제목, 저자, 출판사 등의 키워드로 검색할 수 있습니다.'),
            ])
          : const Text('검색 결과가 없습니다.'),
    );
  }
}
