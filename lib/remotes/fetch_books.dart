import 'dart:async';
import 'dart:convert';

import 'package:galpi/utils/env.dart';
import 'package:http/http.dart' as http;
import 'package:galpi/models/book.dart' show Book;

const kakaoApiEndpoint = "https://dapi.kakao.com/v3/search/book";

Future<List<Book>> fetchBooks({String query}) async {
  if (query == '') {
    return Future.value([]);
  }

  final response = await http.get('${kakaoApiEndpoint}?query=${query}',
      headers: {'Authorization': 'KakaoAK ${env.kakaoRestApiKey}'});

  final books = json.decode(response.body)['documents'];

  final bookIterable = books.map((data) => Book.fromKakaoPayload(data));
  final bookList = bookIterable.toList().cast<Book>();

  return bookList;
}
