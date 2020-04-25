import 'dart:convert';

import 'package:http/http.dart';

class _HttpClient extends BaseClient {
  String token;
  final Client _inner = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    return _inner.send(request);
  }

  // FIXME: 매번 부르는 대신 자동으로 처리되었으면 좋겠다
  T decodeBody<T>(List<int> bodyBytes) {
    return json.decode(utf8.decode(bodyBytes)) as T;
  }
}

final httpClient = _HttpClient();
