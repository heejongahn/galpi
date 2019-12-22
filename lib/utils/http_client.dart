import 'package:http/http.dart';

class _HttpClient extends BaseClient {
  String token;
  final Client _inner = new Client();

  Future<StreamedResponse> send(BaseRequest request) {
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    return _inner.send(request);
  }
}

final httpClient = new _HttpClient();
