import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckLoginUser extends AuthEvent {}

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
