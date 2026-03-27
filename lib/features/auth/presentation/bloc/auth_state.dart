// features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:society_management_app/features/auth/domain/entities/user_login_entity.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../../domain/entities/society_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class CheckingAuth extends AuthState {}

// auth_event.dart

// auth_state.dart (add these)
class CheckingIdentifier extends AuthState {}

class IdentifierNotFound extends AuthState {
  final String message;
  const IdentifierNotFound(this.message);
}

class IdentifierActive extends AuthState {
  final UserLoginEntity identifier;

  const IdentifierActive(this.identifier);
}

class IdentifierPending extends AuthState {
  final UserLoginEntity identifier;
  const IdentifierPending(this.identifier);
}

class IdentifierRejected extends AuthState {
  final String message;
  final UserLoginEntity user;
  const IdentifierRejected(this.message, this.user);
}

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

class SocietyStatusState extends AuthState {
  final UserEntity? user;
  final SocietyEntity? society;
  final String? error;

  const SocietyStatusState({this.user, this.society, this.error});

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

// Add these new states

class EmailOtpSending extends AuthState {}

class EmailOtpSendingSuccess extends AuthState {}

class EmailOtpSendingFailure extends AuthState {
  final String message;
  const EmailOtpSendingFailure(this.message);
}

class EmailOtpVerifying extends AuthState {}

class EmailOtpVerifyingSuccess extends AuthState {}

class EmailOtpVerifyingFailure extends AuthState {
  final String message;
  const EmailOtpVerifyingFailure(this.message);
}

class PhoneOtpSending extends AuthState {}

class PhoneOtpSendingSuccess extends AuthState {}

class PhoneOtpSendingFailure extends AuthState {
  final String message;
  const PhoneOtpSendingFailure(this.message);
}

class PhoneOtpVerifying extends AuthState {}

class PhoneOtpVerifyingSuccess extends AuthState {}

class PhoneOtpVerifyingFailure extends AuthState {
  final String message;
  const PhoneOtpVerifyingFailure(this.message);
}

class SettingPassword extends AuthState {}

class SetPasswordSuccess extends AuthState {}

class SetPasswordFailure extends AuthState {
  final String message;
  const SetPasswordFailure(this.message);
}
