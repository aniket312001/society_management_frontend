// get_current_user_society_usecase.dart
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserSocietyUseCase {
  final AuthRepository repository;

  GetCurrentUserSocietyUseCase(this.repository);

  Future<SocietyEntity?> call() {
    return repository.getCurrentUserSociety();
  }
}
