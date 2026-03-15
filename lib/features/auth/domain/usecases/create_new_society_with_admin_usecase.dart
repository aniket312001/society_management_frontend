// create_new_society_with_admin_usecase.dart
import 'package:society_management_app/features/auth/domain/entities/register_result.dart';
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class CreateNewSocietyWithAdminUseCase {
  final AuthRepository repository;

  CreateNewSocietyWithAdminUseCase(this.repository);

  Future<RegisterResult> call({
    required SocietyEntity society,
    required UserEntity user,
  }) async {
    // Possible future rules:
    // if (society.name.trim().isEmpty) throw ValidationException('Society name required');
    // if (user.role != 'admin') throw ValidationException('User must be admin');

    return await repository.createNewSocietyWithAdmin(
      society: society,
      user: user,
    );
  }
}
