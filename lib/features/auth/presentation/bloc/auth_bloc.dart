// features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_current_user_usecase.dart';
import '../../domain/usecases/create_new_society_with_admin_usecase.dart';
import '../../domain/usecases/email_login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/entities/society_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckCurrentUserUseCase checkCurrentUser;
  final CreateNewSocietyWithAdminUseCase createSociety;
  final EmailLoginUseCase emailLogin;
  final LogoutUseCase logout;

  AuthBloc({
    required this.checkCurrentUser,
    required this.createSociety,
    required this.emailLogin,
    required this.logout,
  }) : super(AuthInitial()) {
    on<CheckLoginUser>(_onCheckLoginUser);
    on<CreateNewSociety>(_onCreateNewSociety);
    on<EmailLoginEvent>(_onEmailLogin);

    on<SendEmailOtp>(_onSendEmailOtp);
    on<VerifyEmailOtp>(_onVerifyEmailOtp);
    on<SendPhoneOtp>(_onSendPhoneOtp);
    on<VerifyPhoneOtp>(_onVerifyPhoneOtp);
    // on<PhoneLogin>(_onPhoneLogin);
    // on<GoogleLogin>(_onGoogleLogin);
  }

  Future<void> _onCheckLoginUser(
    CheckLoginUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(CheckingAuth());

    final result = await checkCurrentUser();

    if (result != null) {
      // Optionally fetch society here too if needed
      emit(Authenticated(result));
    } else {
      emit(UnAuthenticated());
    }
  }

  Future<void> _onCreateNewSociety(
    CreateNewSociety event,
    Emitter<AuthState> emit,
  ) async {
    emit(CreateSocietyLoading());

    final result = await createSociety(
      society: event.societyEntity,
      user: event.userEntity,
    );

    if (result.isSuccess) {
      emit(CreateSocietySuccess(result.admin!, result.society!));
      emit(Authenticated(result.admin!, society: result.society));
    } else {
      emit(
        CreateSocietyFailure(result.errorMessage ?? 'Failed to create society'),
      );
    }
  }

  Future<void> _onEmailLogin(
    EmailLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await emailLogin(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendEmailOtp(
    SendEmailOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await createSociety.repository.sendEmailOtp(event.email);
      emit(EmailOtpSent());
    } catch (e) {
      emit(AuthError("Failed to send email OTP"));
    }
  }

  Future<void> _onVerifyEmailOtp(
    VerifyEmailOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await createSociety.repository.verifyEmailOtp(
        event.email,
        event.otp,
      );

      if (result) {
        emit(EmailOtpVerified());
      } else {
        emit(AuthError("Invalid Email OTP"));
      }
    } catch (e) {
      emit(AuthError("OTP verification failed"));
    }
  }

  Future<void> _onSendPhoneOtp(
    SendPhoneOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await createSociety.repository.sendPhoneOtp(event.phone);
      emit(PhoneOtpSent());
    } catch (e) {
      emit(AuthError("Failed to send phone OTP"));
    }
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await createSociety.repository.verifyPhoneOtp(
        event.phone,
        event.otp,
      );

      if (result) {
        emit(PhoneOtpVerified());
      } else {
        emit(AuthError("Invalid Phone OTP"));
      }
    } catch (e) {
      emit(AuthError("OTP verification failed"));
    }
  }

  // Add logout handler when needed
}
