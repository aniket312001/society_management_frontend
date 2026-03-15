import 'package:society_management_app/core/storage/token_storage.dart';
import 'package:society_management_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:society_management_app/features/auth/data/models/user_model.dart';
import 'package:society_management_app/features/auth/domain/entities/register_result.dart';
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<UserEntity?> checkCurrentUser() async {
    final token = await tokenStorage.getValidToken();
    if (token == null) {
      return null;
    }

    try {
      final userModel = await remoteDataSource.getCurrentUserProfile();
      return userModel?.toEntity();
    } catch (e) {
      // Any unexpected error → treat as unauthenticated
      await tokenStorage.clearToken();
      return null;
    }
  }

  @override
  Future<RegisterResult> createNewSocietyWithAdmin({
    required SocietyEntity society,
    required UserEntity user,
  }) async {
    return await remoteDataSource.createSocietyWithAdmin(society, user);
  }

  @override
  Future<UserEntity> emailLogin({
    required String email,
    required String password,
  }) {
    // TODO: implement emailLogin
    throw UnimplementedError();
  }

  @override
  Future<SocietyEntity?> getCurrentUserSociety() {
    // TODO: implement getCurrentUserSociety
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> googleLogin() {
    // TODO: implement googleLogin
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> phoneLogin({
    required String phoneNumber,
    required String otp,
  }) {
    // TODO: implement phoneLogin
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> refreshSession() {
    // TODO: implement refreshSession
    throw UnimplementedError();
  }

  @override
  Future<void> sendPhoneOtp(String phoneNumber) {
    // TODO: implement sendPhoneOtp
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    await remoteDataSource.sendEmailOtp(email);
  }

  @override
  Future<bool> verifyEmailOtp(String email, String otp) async {
    return await remoteDataSource.verifyEmailOtp(email, otp);
  }

  @override
  Future<bool> verifyPhoneOtp(String phone, String otp) async {
    return await remoteDataSource.verifyPhoneOtp(phone, otp);
  }
}
