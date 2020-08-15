import 'package:flutter/material.dart';

enum Status {
  idle,
  loading,
  fetchedAll,
}

typedef ItemBuilder<T> = Widget Function(T, {int index});
typedef FetchMore<T> = Future<bool> Function();

class InfiniteScrollListViewState<T> extends State<InfiniteScrollListView<T>> {
  var status = Status.idle;

  Widget _buildRows() {
    final data = widget.data;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 72),
      itemCount: status == Status.fetchedAll ? data.length : null,
      itemBuilder: (context, i) {
        if (i > data.length) {
          return null;
        }

        if (i == data.length) {
          _fetchItems();

          if (data.isEmpty) {
            return Container(
              height: 400,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }

          return Container(
            padding: const EdgeInsets.symmetric(
              vertical: 48,
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        }

        final Widget child = widget.itemBuilder(data[i], index: i);

        return Container(
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return status == Status.fetchedAll && widget.data.isEmpty
        ? widget.emptyWidget
        : _buildRows();
  }

  Future<void> _fetchItems() async {
    if (status == Status.loading) {
      return;
    }

    status = Status.loading;

    final canLoadMore = await widget.fetchMore();
    if (mounted) {
      setState(() {
        status = canLoadMore ? Status.idle : Status.fetchedAll;
      });
    }
  }
}

class InfiniteScrollListView<T> extends StatefulWidget {
  final List<T> data;
  final FetchMore<T> fetchMore;
  final ItemBuilder<T> itemBuilder;
  final Widget emptyWidget;

  const InfiniteScrollListView({
    Key key,
    @required this.data,
    @required this.fetchMore,
    @required this.itemBuilder,
    @required this.emptyWidget,
  }) : super(key: key);

  @override
  InfiniteScrollListViewState<T> createState() =>
      InfiniteScrollListViewState<T>();
}
