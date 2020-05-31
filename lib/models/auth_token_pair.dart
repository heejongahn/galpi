class AuthTokenPair {
  final String token;
  final String refreshToken;

  const AuthTokenPair({this.token, this.refreshToken});

  static AuthTokenPair fromBody(Map<String, dynamic> body) {
    final token = body['token'] as String;
    final refreshToken = body['refreshToken'] as String;

    if (token != null && refreshToken != null) {
      return AuthTokenPair(token: token, refreshToken: refreshToken);
    } else {
      throw 'AuthTokenPair.fromBody failed';
    }
  }
}
