import 'package:get_it/get_it.dart';
import 'package:society_management_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:society_management_app/features/auth/domain/usecases/check_user_exist_usecase.dart';
import 'package:society_management_app/features/auth/domain/usecases/get_current_user_society_usecase.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

import '../../features/auth/domain/usecases/check_current_user_usecase.dart';
import '../../features/auth/domain/usecases/create_new_society_with_admin_usecase.dart';
import '../../features/auth/domain/usecases/email_login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../network/dio_client.dart';
import '../storage/token_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// CORE

  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => TokenStorage());

  /// DATASOURCE
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );

  /// REPOSITORY
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl()),
  );

  /// USECASES
  sl.registerLazySingleton(() => CheckCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => CreateNewSocietyWithAdminUseCase(sl()));
  sl.registerLazySingleton(() => EmailLoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserSocietyUseCase(sl()));
  sl.registerLazySingleton(() => CheckUserExistUseCase(sl()));

  /// BLOC
  sl.registerFactory(
    () => AuthBloc(
      checkCurrentUser: sl(),
      createSociety: sl(),
      emailLogin: sl(),
      logout: sl(),
      currentUserSocietyUseCase: sl(),
      checkUserExistUseCase: sl(),
    ),
  );
}
