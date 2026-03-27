import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/user/domain/repositories/user_repository.dart';

class CreateUserUsecase {
  final UserRepository repository;

  CreateUserUsecase(this.repository);

  Future<UserEntity> call({required UserEntity data}) async {
    return await repository.createUser(data);
  }
}
