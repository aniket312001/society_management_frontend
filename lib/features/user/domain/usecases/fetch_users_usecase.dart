// check_current_user_usecase.dart
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:society_management_app/features/user/domain/repositories/user_repository.dart';

class FetchUsersUsecase {
  final UserRepository repository;

  FetchUsersUsecase(this.repository);

  Future<List<UserEntity>> call({
    required int page,
    String? status,
    String? role,
    String? search,
  }) async {
    return await repository.getUsers(
      page: page,
      role: role,
      search: search,
      status: status,
    );
  }
}
