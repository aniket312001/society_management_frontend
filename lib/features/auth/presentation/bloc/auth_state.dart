// features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/society_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class CheckingAuth extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  final SocietyEntity? society; // can be null if not loaded yet

  const Authenticated(this.user, {this.society});

  @override
  List<Object?> get props => [user, society];
}

class UnAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Registration specific states ────────────────────────────────

class CreateSocietyLoading extends AuthState {}

class CreateSocietySuccess extends AuthState {
  final UserEntity user;
  final SocietyEntity society;

  const CreateSocietySuccess(this.user, this.society);

  @override
  List<Object?> get props => [user, society];
}

class CreateSocietyFailure extends AuthState {
  final String message;
  const CreateSocietyFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class EmailOtpSent extends AuthState {}

class EmailOtpVerified extends AuthState {}

class PhoneOtpSent extends AuthState {}

class PhoneOtpVerified extends AuthState {}
