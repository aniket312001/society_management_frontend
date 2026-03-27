import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

// ─── Page States ─────────────────────────────────────────────────────────────

class UserInitial extends UserState {}

class UserPageLoading extends UserState {}

class UserPageLoaded extends UserState {
  final List<UserEntity> users;
  final bool hasMore;
  final int page;

  final String? message; // ✅ added
  final bool isError; // ✅ added

  const UserPageLoaded({
    required this.users,
    required this.hasMore,
    required this.page,
    this.message,
    this.isError = false,
  });

  @override
  List<Object?> get props => [users, hasMore, page, message, isError];
}

class UserPageError extends UserState {
  final String message;
  const UserPageError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Form States (signals only — no data) ────────────────────────────────────

class UserFormLoading extends UserState {}

class UserFormSuccess extends UserState {
  final String message;
  const UserFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
} // just a signal to pop/snackbar

class UserFormError extends UserState {
  final String message;
  const UserFormError(this.message);

  @override
  List<Object?> get props => [message];
}
