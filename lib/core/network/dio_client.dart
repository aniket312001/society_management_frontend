import '../constants/api_constants.dart';

import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import '../di/injector.dart';

class DioClient {
  final Dio dio = Dio();

  DioClient() {
    dio.options.baseUrl = ApiConstants.baseUrl;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await sl<TokenStorage>().getToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },

        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            /// Token expired
            /// Later we will logout user
          }

          return handler.next(error);
        },
      ),
    );
  }
}
