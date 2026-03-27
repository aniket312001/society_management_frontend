import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import '../di/injector.dart'; // your get_it / service locator

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await sl<TokenStorage>().getValidToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onError: (err, handler) async {
          // Only token handling here
          if (err.response?.statusCode == 401 ||
              err.response?.statusCode == 403) {
            await sl<TokenStorage>().clearToken();
          }

          return handler.next(err); // IMPORTANT: don't transform here
        },
      ),
    );
  }
}
