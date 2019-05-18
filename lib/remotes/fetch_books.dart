import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../screens/book_list/index.dart';

const API_ENDPOINT = "https://dapi.kakao.com/v3/search/book";
const API_KEY = "04180f02a662d58371bb715b54ce4c7b";

Future<Book> fetchBooks({String query}) async {
  final books = await http.get('${API_ENDPOINT}?query=${query}',
      headers: {'Authorization': 'KakaoAK ${API_KEY}'});
  return Book.fromPayload(json.decode(books.body));
}
