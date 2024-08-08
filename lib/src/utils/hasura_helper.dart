import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'hasura_token_interceptor.dart';

class HasuraHelper {
  static HasuraConnect? hasuraConnect;

  static HasuraConnect get hasuraHelper {
    hasuraConnect = HasuraConnect(
      dotenv.env['HASURA_ENDPOINT']!,
      interceptors: [TokenInterceptor()],
    );
    return hasuraConnect!;
  }
}
