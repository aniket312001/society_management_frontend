// features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:society_management_app/features/auth/domain/entities/user_login_entity.dart';
import 'package:society_management_app/features/auth/domain/usecases/check_user_exist_usecase.dart';
import 'package:society_management_app/features/auth/domain/usecases/get_current_user_society_usecase.dart';
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
  final GetCurrentUserSocietyUseCase currentUserSocietyUseCase;
  final CheckUserExistUseCase checkUserExistUseCase;

  AuthBloc({
    required this.checkCurrentUser,
    required this.createSociety,
    required this.currentUserSocietyUseCase,
    required this.emailLogin,
    required this.logout,
    required this.checkUserExistUseCase,
  }) : super(AuthInitial()) {
    on<CheckLoginUser>(_onCheckLoginUser);
    on<CreateNewSociety>(_onCreateNewSociety);
    on<EmailLoginEvent>(_onEmailLogin);

    on<SendEmailOtp>(_onSendEmailOtp);
    on<VerifyEmailOtp>(_onVerifyEmailOtp);
    on<SendPhoneOtp>(_onSendPhoneOtp);
    on<VerifyPhoneOtp>(_onVerifyPhoneOtp);
    on<CheckUserIdentifier>(_checkUserIdentifier);
    // on<PhoneLogin>(_onPhoneLogin);
    // on<GoogleLogin>(_onGoogleLogin);
  }

  String _parseError(Object e) {
    if (e is ServerException) return e.message;
    if (e is ValidationException) return e.message;
    if (e is ConflictException) return e.message;
    if (e is UnauthorizedException) return e.message;
    if (e is NetworkException) return e.message;
    // Fallback: strip "Exception: " prefix dart adds
    final raw = e.toString();
    if (raw.startsWith('Exception: ')) return raw.substring(11);
    return raw;
  }

  Future<void> _onCheckLoginUser(
    CheckLoginUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(CheckingAuth());

    final result = await checkCurrentUser();

    if (result != null) {
      // Optionally fetch society here too if needed
      // emit(Authenticated(result));

      // Always check society status on app start
      await _navigateBasedOnSocietyStatus(emit, result);
    } else {
      emit(UnAuthenticated());
    }
  }

  Future<void> _navigateBasedOnSocietyStatus(
    Emitter<AuthState> emit,
    UserEntity user,
  ) async {
    try {
      final society = await currentUserSocietyUseCase(); // use your use case

      if (society == null) return;

      emit(SocietyStatusState(user: user, society: society));
      // emit(Authenticated(user));
    } catch (e) {
      emit(SocietyStatusState(error: _parseError(e)));
      // emit(SocietyStatusState(user: user, errorMessage: _parseError(e)));
    }
  }

  Future<void> _onCreateNewSociety(
    CreateNewSociety event,
    Emitter<AuthState> emit,
  ) async {
    emit(CreateSocietyLoading());

    try {
      final result = await createSociety(
        society: event.societyEntity,
        user: event.userEntity,
      );

      if (result.isSuccess) {
        emit(CreateSocietySuccess(result.admin!, result.society!));
        emit(Authenticated(result.admin!, society: result.society));
      } else {
        emit(
          CreateSocietyFailure(
            result.errorMessage ?? 'Failed to create society',
          ),
        );
      }
    } catch (e) {
      emit(
        CreateSocietyFailure(_parseError(e)),
      ); // ← this catch is what's missing
    }
  }

  Future<void> _checkUserIdentifier(
    CheckUserIdentifier event,
    Emitter<AuthState> emit,
  ) async {
    UserLoginEntity? user = await checkUserExistUseCase(
      event.identifier,
      event.isEmail,
    );

    if (user == null || (user != null && user.exists == false)) {
      emit(IdentifierNotFound("User Doesn't exist"));
    } else {
      if (user.status == "pending") {
        emit(IdentifierPending(user));
      } else if (user.status == "active") {
        emit(IdentifierActive(user));
      } else {
        emit(IdentifierRejected(event.identifier, user));
      }
    }
    return;
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
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onSendEmailOtp(
    SendEmailOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(EmailOtpSending());

    try {
      await createSociety.repository.sendEmailOtp(event.email);
      emit(EmailOtpSendingSuccess());
    } catch (e) {
      emit(EmailOtpSendingFailure(e.toString()));
    }
  }

  Future<void> _onVerifyEmailOtp(
    VerifyEmailOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(EmailOtpVerifying());

    try {
      final success = await createSociety.repository.verifyEmailOtp(
        event.email,
        event.otp,
      );
      if (success) {
        emit(EmailOtpVerifyingSuccess());
      } else {
        emit(EmailOtpVerifyingFailure("Invalid or expired OTP"));
      }
    } catch (e) {
      emit(EmailOtpVerifyingFailure(_parseError(e)));
    }
  }

  // Same pattern for Phone
  Future<void> _onSendPhoneOtp(
    SendPhoneOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(PhoneOtpSending());
    try {
      await createSociety.repository.sendPhoneOtp(event.phone);
      emit(PhoneOtpSendingSuccess());
    } catch (e) {
      emit(PhoneOtpSendingFailure(_parseError(e)));
    }
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(PhoneOtpVerifying());
    try {
      final success = await createSociety.repository.verifyPhoneOtp(
        event.phone,
        event.otp,
      );
      if (success) {
        emit(PhoneOtpVerifyingSuccess());
      } else {
        emit(PhoneOtpVerifyingFailure("Invalid or expired OTP"));
      }
    } catch (e) {
      emit(PhoneOtpVerifyingFailure(_parseError(e)));
    }
  }

  // Add logout handler when needed
}
