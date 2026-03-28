import 'package:get_it/get_it.dart';
import 'package:society_management_app/features/announcements/data/datasource/announcement_remote_datasource.dart';
import 'package:society_management_app/features/announcements/data/repositories/announcement_repositoryImp.dart';
import 'package:society_management_app/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:society_management_app/features/announcements/domain/usecases/create_announcement_usecase.dart';
import 'package:society_management_app/features/announcements/domain/usecases/delete_announcement_usecase.dart';
import 'package:society_management_app/features/announcements/domain/usecases/fetch_active_announcement_usecase.dart';
import 'package:society_management_app/features/announcements/domain/usecases/fetch_announcement_usecase.dart';
import 'package:society_management_app/features/announcements/domain/usecases/update_announcement_usecase.dart';
import 'package:society_management_app/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:society_management_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:society_management_app/features/auth/domain/usecases/check_user_exist_usecase.dart';
import 'package:society_management_app/features/auth/domain/usecases/get_current_user_society_usecase.dart';
import 'package:society_management_app/features/auth/domain/usecases/phone_login_usecase.dart';
import 'package:society_management_app/features/auth/domain/usecases/set_password_usecase.dart';
import 'package:society_management_app/features/posts/data/datasource/post_remote_datasource.dart';
import 'package:society_management_app/features/posts/data/repositories/post_repositoryImp.dart';
import 'package:society_management_app/features/posts/domain/repositories/post_repository.dart';
import 'package:society_management_app/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/fetch_post_comments.dart';
import 'package:society_management_app/features/posts/domain/usecases/fetch_posts_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/like_post_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/unlike_post_usecase.dart';
import 'package:society_management_app/features/posts/presentation/bloc/comments/comment_bloc.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_bloc.dart';
import 'package:society_management_app/features/user/data/datasources/user_remote_data_source.dart';
import 'package:society_management_app/features/user/data/repositories/user_repository_impl.dart';
import 'package:society_management_app/features/user/domain/repositories/user_repository.dart';
import 'package:society_management_app/features/user/domain/usecases/create_user_usecase.dart';
import 'package:society_management_app/features/user/domain/usecases/fetch_users_usecase.dart';
import 'package:society_management_app/features/user/domain/usecases/update_user_usecase.dart';
import 'package:society_management_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:society_management_app/features/visitors/data/datasource/visitor_remote_data_source.dart';
import 'package:society_management_app/features/visitors/data/repositories/visitor_repository_impl.dart';
import 'package:society_management_app/features/visitors/domain/repositories/visitor_repository.dart';
import 'package:society_management_app/features/visitors/domain/usecases/create_visitor_usecase.dart';
import 'package:society_management_app/features/visitors/domain/usecases/delete_visitor_usecase.dart';
import 'package:society_management_app/features/visitors/domain/usecases/fetch_visitors_usecase.dart';
import 'package:society_management_app/features/visitors/domain/usecases/update_visitor_status_usecase.dart';
import 'package:society_management_app/features/visitors/domain/usecases/update_visitor_usecase.dart';
import 'package:society_management_app/features/visitors/presentation/bloc/visitor_bloc.dart';

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
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl()),
  );
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  // Visitor
  sl.registerLazySingleton(() => VisitorRemoteDataSource(sl()));
  sl.registerLazySingleton<VisitorRepository>(
    () => VisitorRepositoryImpl(sl()),
  );

  // announcements
  sl.registerLazySingleton(() => AnnouncementRemoteDataSource(sl()));
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepositoryImpl(sl()),
  );

  // post
  sl.registerLazySingleton(() => PostRemoteDataSource(sl()));
  sl.registerLazySingleton<PostRepository>(() => PostRepositoryImpl(sl()));

  /// USECASES
  sl.registerLazySingleton(() => CheckCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => CreateNewSocietyWithAdminUseCase(sl()));
  sl.registerLazySingleton(() => EmailLoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserSocietyUseCase(sl()));
  sl.registerLazySingleton(() => CheckUserExistUseCase(sl()));
  sl.registerLazySingleton(() => SetNewPasswordUseCase(sl()));
  sl.registerLazySingleton(() => PhoneLoginUseCase(sl()));

  sl.registerLazySingleton(() => FetchUsersUsecase(sl()));
  sl.registerLazySingleton(() => UpdateUserUsecase(sl()));
  sl.registerLazySingleton(() => CreateUserUsecase(sl()));

  sl.registerLazySingleton(() => FetchVisitorsUsecase(sl()));
  sl.registerLazySingleton(() => CreateVisitorUsecase(sl()));
  sl.registerLazySingleton(() => UpdateVisitorUsecase(sl()));
  sl.registerLazySingleton(() => UpdateVisitorStatusUsecase(sl()));
  sl.registerLazySingleton(() => DeleteVisitorUsecase(sl()));

  sl.registerLazySingleton(() => FetchAnnouncementsUsecase(sl()));
  sl.registerLazySingleton(() => FetchActiveAnnouncementsUsecase(sl()));
  sl.registerLazySingleton(() => CreateAnnouncementUsecase(sl()));
  sl.registerLazySingleton(() => UpdateAnnouncementUsecase(sl()));
  sl.registerLazySingleton(() => DeleteAnnouncementUsecase(sl()));

  //post
  sl.registerLazySingleton(() => AddCommentUsecase(sl()));
  sl.registerLazySingleton(() => CreatePostUsecase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUsecase(sl()));
  sl.registerLazySingleton(() => DeletePostUsecase(sl()));
  sl.registerLazySingleton(() => FetchCommentsUsecase(sl()));
  sl.registerLazySingleton(() => FetchPostsUsecase(sl()));
  sl.registerLazySingleton(() => LikePostUsecase(sl()));
  sl.registerLazySingleton(() => UnlikePostUsecase(sl()));

  /// BLOC
  sl.registerFactory(
    () => AuthBloc(
      checkCurrentUser: sl(),
      createSociety: sl(),
      emailLogin: sl(),
      logout: sl(),
      currentUserSocietyUseCase: sl(),
      checkUserExistUseCase: sl(),
      setNewPassword: sl(),
      phoneLogin: sl(),
    ),
  );

  sl.registerFactory(() => UserBloc(sl(), sl(), sl()));

  sl.registerFactory(
    () => VisitorBloc(
      fetchVisitorsUsecase: sl(),
      createVisitorUsecase: sl(),
      updateVisitorUsecase: sl(),
      updateVisitorStatusUsecase: sl(),
      deleteVisitorUsecase: sl(),
    ),
  );

  sl.registerFactory(
    () => AnnouncementBloc(
      createAnnouncementUsecase: sl(),
      deleteAnnouncementUsecase: sl(),
      fetchActiveAnnouncementsUsecase: sl(),
      fetchAnnouncementsUsecase: sl(),
      updateAnnouncementUsecase: sl(),
    ),
  );

  sl.registerFactory(
    () => PostBloc(
      fetchPostsUsecase: sl(),
      createPostUsecase: sl(),
      deletePostUsecase: sl(),
      likePostUsecase: sl(),
      unlikePostUsecase: sl(),
    ),
  );
  sl.registerFactory(
    () => CommentBloc(
      fetchCommentsUsecase: sl(),
      addCommentUsecase: sl(),
      deleteCommentUsecase: sl(),
    ),
  );
}
