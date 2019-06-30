import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:galpi/utils/secret.dart';
import 'package:galpi/models/book.dart' show Book;

const API_ENDPOINT = "https://dapi.kakao.com/v3/search/book";

Future<List<Book>> fetchBooks({String query}) async {
  Secret secret = await SecretLoader(secretPath: "secrets/keys.json").load();

  final response = await http.get('${API_ENDPOINT}?query=${query}',
      headers: {'Authorization': 'KakaoAK ${secret.kakaoRestApiKey}'});

  final books = json.decode(response.body)['documents'];

  final bookIterable = books.map((data) => Book.fromPayload(data));
  final bookList = bookIterable.toList().cast<Book>();

  return bookList;
}
