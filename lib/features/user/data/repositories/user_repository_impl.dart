import 'package:society_management_app/features/user/data/datasources/user_remote_data_source.dart';
import 'package:society_management_app/features/user/data/models/user_model.dart';
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;

  UserRepositoryImpl(this.remote);

  @override
  Future<List<UserEntity>> getUsers({
    required int page,
    String? status,
    String? role,
    String? search,
  }) async {
    final result = await remote.getUsers(
      page: page,
      status: status,
      role: role,
      search: search,
    );

    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<UserEntity> updateUser({
    required int userId,
    required UserEntity data,
  }) async {
    final result = await remote.updateUser(userId: userId, data: data);

    return result.toEntity();
  }

  @override
  Future<UserEntity> createUser(UserEntity data) async {
    return await remote.createUser(data);
  }
}
