// ignore_for_file: avoid_print

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hasura_connect/hasura_connect.dart';
// import 'dart:developer' as developer;
// import 'utils.dart';

class TokenInterceptor extends InterceptorBase {
  TokenInterceptor();
  @override
  Future? onRequest(Request request, HasuraConnect connect) async {
    // String? token = await JwtDecoder.gettoken();

    try {
      // request.headers["Authorization"] = "Bearer $token";
      // developer.log("\x1B[32m$token\x1B[0m");
      request.headers["x-hasura-admin-secret"] = dotenv.env['SRECRETE']!;
      return request;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
