import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:society_management_app/features/auth/domain/entities/user_login_entity.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckLoginUser extends AuthEvent {}

class CheckUserIdentifier extends AuthEvent {
  final bool isEmail;
  final String identifier; // email or phone
  CheckUserIdentifier(this.identifier, this.isEmail);

  @override
  List<Object?> get props => [identifier, isEmail];
}

class SendBothOtpEmailPhone extends AuthEvent {
  UserLoginEntity identifier;
  SendBothOtpEmailPhone(this.identifier);
}

class VerifyEmailPhoneOtp extends AuthEvent {
  UserLoginEntity identifier;
  String phoneOTP;
  String emailOTP;
  VerifyEmailPhoneOtp({
    required this.identifier,
    required this.emailOTP,
    required this.phoneOTP,
  });
}

class SetNewPassword extends AuthEvent {
  UserLoginEntity identifier;
  String newPassword;
  SetNewPassword({required this.identifier, required this.newPassword});
}

class CreateNewSociety extends AuthEvent {
  SocietyEntity societyEntity;
  UserEntity userEntity;
  CreateNewSociety({required this.societyEntity, required this.userEntity});

  @override
  List<Object?> get props => [societyEntity, userEntity];
}

class EmailLoginEvent extends AuthEvent {
  String email;
  String password;
  EmailLoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class PhoneLogin extends AuthEvent {}

class GoogleLogin extends AuthEvent {}

class SendEmailOtp extends AuthEvent {
  final String email;
  SendEmailOtp(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyEmailOtp extends AuthEvent {
  final String email;
  final String otp;

  VerifyEmailOtp({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class SendPhoneOtp extends AuthEvent {
  final String phone;

  SendPhoneOtp(this.phone);

  @override
  List<Object?> get props => [phone];
}

class VerifyPhoneOtp extends AuthEvent {
  final String phone;
  final String otp;

  VerifyPhoneOtp({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}
