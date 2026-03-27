import 'package:society_management_app/core/storage/token_storage.dart';
import 'package:society_management_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:society_management_app/features/auth/data/models/society_model.dart';
import 'package:society_management_app/features/auth/data/models/user_login_model.dart';
import 'package:society_management_app/features/user/data/models/user_model.dart';
import 'package:society_management_app/features/auth/domain/entities/register_result.dart';
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_login_entity.dart';
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
  Future<SocietyEntity?> getCurrentUserSociety() async {
    // TODO: implement getCurrentUserSociety
    final societyModel = await remoteDataSource.getMySociety();
    return societyModel?.toEntity();
  }

  @override
  Future<UserLoginEntity> checkUserLogin({
    required String identifier,
    required bool isEmail,
  }) async {
    UserLoginModel loginModel = await remoteDataSource.checkUserLogin(
      identifier: identifier,
      isEmail: isEmail,
    );
    return loginModel.toEntity();
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
  }) async {
    return await remoteDataSource.emailLogin(email: email, password: password);
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
  }) async {
    return await remoteDataSource.phoneLogin(phone: phoneNumber, otp: otp);
  }

  @override
  Future<UserEntity> refreshSession() {
    // TODO: implement refreshSession
    throw UnimplementedError();
  }

  @override
  Future<void> sendPhoneOtp(String phoneNumber) async {
    // TODO: implement sendPhoneOtp
    return await remoteDataSource.sendPhoneOtp(phoneNumber);
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

  @override
  Future<UserEntity?> setNewPassword(int id, String newPassword) async {
    // TODO: implement setNewPassword
    var userModel = await remoteDataSource.setNewPassword(id, newPassword);

    return userModel?.toEntity();
  }
}
