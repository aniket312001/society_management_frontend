import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => DioClient());

  sl.registerLazySingleton(() => TokenStorage());
}
