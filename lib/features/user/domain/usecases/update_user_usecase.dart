import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/user/domain/repositories/user_repository.dart';

class UpdateUserUsecase {
  final UserRepository repository;

  UpdateUserUsecase(this.repository);

  Future<UserEntity> call({
    required int userId,
    required UserEntity data,
  }) async {
    return await repository.updateUser(userId: userId, data: data);
  }
}
