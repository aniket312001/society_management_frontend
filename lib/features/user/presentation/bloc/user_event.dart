import 'package:society_management_app/features/user/domain/entities/user_entity.dart';

abstract class UserEvent {}

class FetchUsers extends UserEvent {
  final int page;
  final String? status;
  final String? role;
  final String? search;

  FetchUsers({this.page = 1, this.status, this.role, this.search});
}

class LoadMoreUsers extends UserEvent {}

class UpdateUserStatus extends UserEvent {
  final UserEntity user;
  final String status;

  UpdateUserStatus(this.user, this.status);
}

class CreateUser extends UserEvent {
  final UserEntity user;

  CreateUser(this.user);
}
