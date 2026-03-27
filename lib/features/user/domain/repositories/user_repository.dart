import 'package:society_management_app/features/user/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers({
    required int page,
    String? status,
    String? role,
    String? search,
  });

  Future<UserEntity> updateUser({
    required int userId,
    required UserEntity data,
  });

  Future<UserEntity> createUser(UserEntity data);
}
