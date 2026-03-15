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
          print("hitting api");
          final token = await sl<TokenStorage>().getValidToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onError: (DioException err, ErrorInterceptorHandler handler) async {
          print("Error in api - ${err}");
          // ── Critical part: handle 401 globally ────────────────────────
          if (err.response?.statusCode == 401 ||
              err.response?.statusCode == 403) {
            // Token invalid / expired according to backend
            await sl<TokenStorage>().clearToken();

            // Option A: Just let the request fail (simplest)
            // The calling use-case / bloc can catch and trigger logout

            // Option B: Emit global logout event (recommended if using Bloc/Riverpod)
            // sl<AuthBloc>().add(LogoutRequested());

            // Option C: Show toast / dialog here (not recommended – better in UI layer)

            // For now → reject with custom error so caller knows
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                error: 'Session expired. Please login again.',
                type: DioExceptionType.badResponse,
              ),
            );
          }

          // Other errors → pass through
          return handler.next(err);
        },
      ),
    );
  }
}
