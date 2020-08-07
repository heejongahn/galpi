import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:galpi/utils/flavor.dart';

const _KEY_kakaoRestApiKey = 'KAKAO_REST_API_KEY';
const _KEY_apiEndpoint = 'API_ENDPOINT';
const _KEY_webEndpoint = 'WEB_ENDPOINT';
const _KEY_sentryDSN = 'SENTRY_DSN';

class Env {
  String kakaoRestApiKey;
  String apiEndpoint;
  String webEndpoint;
  String sentryDSN;
}

final env = Env();

final _dotEnv = DotEnv();
const _vars = [
  _KEY_kakaoRestApiKey,
  _KEY_apiEndpoint,
  _KEY_sentryDSN,
];

String _getEnvFileName(Flavor flavor) {
  switch (flavor) {
    case Flavor.dev:
      {
        return '.env.dev';
      }
    case Flavor.prod:
      {
        return '.env.prod';
      }
    default:
      {
        return 'env.dev';
      }
  }
}

Future<void> loadEnvForCurrentFlavor() async {
  final flavor = await getCurrentFlavor();
  final envFileName = _getEnvFileName(flavor);

  await _dotEnv.load('assets/$envFileName');

  if (!_dotEnv.isEveryDefined(_vars)) {
    throw '$envFileName: Not all environment variables were provided.';
  }

  env.kakaoRestApiKey = _dotEnv.env[_KEY_kakaoRestApiKey];
  env.apiEndpoint = _dotEnv.env[_KEY_apiEndpoint];
  env.webEndpoint = _dotEnv.env[_KEY_webEndpoint];
  env.sentryDSN = _dotEnv.env[_KEY_sentryDSN];

  print(env.apiEndpoint);
}
