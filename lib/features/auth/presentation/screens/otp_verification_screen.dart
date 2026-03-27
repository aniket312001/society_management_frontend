import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:society_management_app/core/widgets/app_button.dart';
import 'package:society_management_app/core/widgets/app_text_field.dart';
import 'package:society_management_app/features/auth/domain/entities/user_login_entity.dart';
import 'package:society_management_app/features/society/screens/home_screen.dart';
import 'package:society_management_app/features/society/screens/society_status_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final UserLoginEntity identifier;

  const OtpVerificationScreen({super.key, required this.identifier});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _passwordController = TextEditingController();
  final _emailOtpController = TextEditingController();
  final _phoneOtpController = TextEditingController();

  String? _passwordError;
  String? _emailOtpError;
  String? _phoneOtpError;

  bool _emailOtpSent = false;
  bool _phoneOtpSent = false;
  bool _emailVerified = false;
  bool _phoneVerified = false;

  bool _isSendingEmail = false;
  bool _isSendingPhone = false;
  bool _isVerifyingEmail = false;
  bool _isVerifyingPhone = false;
  bool _isSaving = false;

  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailOtpController.dispose();
    _phoneOtpController.dispose();
    super.dispose();
  }

  // ── Send OTP Handlers ──────────────────────────────────────────────

  void _sendEmailOtp() {
    setState(() => _isSendingEmail = true);
    context.read<AuthBloc>().add(SendEmailOtp(widget.identifier.email));
  }

  void _sendPhoneOtp() {
    setState(() => _isSendingPhone = true);
    context.read<AuthBloc>().add(SendPhoneOtp(widget.identifier.phone));
  }

  // ── Verify OTP Handlers ────────────────────────────────────────────

  void _verifyEmailOtp() {
    final otp = _emailOtpController.text.trim();
    if (otp.length != 6) {
      setState(() => _emailOtpError = 'Enter 6-digit OTP');
      return;
    }
    setState(() => _emailOtpError = null);
    setState(() => _isVerifyingEmail = true);
    context.read<AuthBloc>().add(
      VerifyEmailOtp(email: widget.identifier.email, otp: otp),
    );
  }

  void _verifyPhoneOtp() {
    final otp = _phoneOtpController.text.trim();
    if (otp.length != 6) {
      setState(() => _phoneOtpError = 'Enter 6-digit OTP');
      return;
    }
    setState(() => _phoneOtpError = null);
    setState(() => _isVerifyingPhone = true);
    context.read<AuthBloc>().add(
      VerifyPhoneOtp(phone: widget.identifier.phone, otp: otp),
    );
  }

  // ── Save Password & Login ──────────────────────────────────────────

  void _savePasswordAndLogin() {
    final password = _passwordController.text.trim();

    if (!_emailVerified) {
      setState(() => _passwordError = 'Email is not verified');
      return;
    }

    if (!_phoneVerified) {
      setState(() => _passwordError = 'Phone is not verified');
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordError = 'Minimum 6 characters');
      return;
    }

    setState(() => _passwordError = null);
    setState(() => _isSaving = true);

    context.read<AuthBloc>().add(
      SetNewPassword(
        identifier: widget.identifier, // or phone – adjust as needed
        newPassword: password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify & Set Password')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Email OTP

          if (state is Authenticated ||
              (state is SocietyStatusState &&
                  state.society?.status == "approved")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is SocietyStatusState &&
              state.society != null &&
              state.user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SocietyStatusScreen(
                  user: state.user!,
                  society: state.society,
                  errorMessage: state.error,
                ),
              ),
            );
          }

          if (state is EmailOtpSending) {
            setState(() => _isSendingEmail = true);
          }
          if (state is EmailOtpSendingSuccess) {
            setState(() {
              _isSendingEmail = false;
              _emailOtpSent = true;
              _emailOtpError = null;
            });
          }
          if (state is EmailOtpSendingFailure) {
            setState(() {
              _isSendingEmail = false;
              _emailOtpError = state.message;
            });
          }

          if (state is EmailOtpVerifying) {
            setState(() => _isVerifyingEmail = true);
          }
          if (state is EmailOtpVerifyingSuccess) {
            setState(() {
              _isVerifyingEmail = false;
              _emailVerified = true;
            });
          }
          if (state is EmailOtpVerifyingFailure) {
            setState(() {
              _isVerifyingEmail = false;
              _emailOtpError = state.message;
            });
          }

          // Phone OTP – same pattern
          if (state is PhoneOtpSending) {
            setState(() => _isSendingPhone = true);
          }
          if (state is PhoneOtpSendingSuccess) {
            setState(() {
              _isSendingPhone = false;
              _phoneOtpSent = true;
              _phoneOtpError = null;
            });
          }
          if (state is PhoneOtpSendingFailure) {
            setState(() {
              _isSendingPhone = false;
              _phoneOtpError = state.message;
            });
          }

          if (state is PhoneOtpVerifying) {
            setState(() => _isVerifyingPhone = true);
          }
          if (state is PhoneOtpVerifyingSuccess) {
            setState(() {
              _isVerifyingPhone = false;
              _phoneVerified = true;
            });
          }
          if (state is PhoneOtpVerifyingFailure) {
            setState(() {
              _isVerifyingPhone = false;
              _phoneOtpError = state.message;
            });
          }

          // Set Password
          if (state is SettingPassword) {
            setState(() => _isSaving = true);
          }
          if (state is SetPasswordSuccess) {
            setState(() => _isSaving = false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
          if (state is SetPasswordFailure) {
            setState(() {
              _isSaving = false;
              _passwordError = state.message;
            });
          }

          // Final navigation
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
          if (state is SocietyStatusState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SocietyStatusScreen(
                  user: state.user!,
                  society: state.society,
                  errorMessage: state.error,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isAnyLoading =
              _isSendingEmail ||
              _isSendingPhone ||
              _isVerifyingEmail ||
              _isVerifyingPhone ||
              _isSaving;

          final canSave = _emailVerified && _phoneVerified && !isAnyLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Set Password & Verify',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your account is pending approval.\nVerify both channels and set a password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),

                // ── New Password Field (always visible) ────────────────────────
                AppTextField(
                  controller: _passwordController,
                  label: 'New Password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  errorText: _passwordError,
                ),
                const SizedBox(height: 16),

                // ── Email Verification Section ─────────────────────────────────
                Text('Email: ${widget.identifier.email}'),
                const SizedBox(height: 8),

                if (!_emailOtpSent && !_emailVerified)
                  AppButton(
                    text: _isSendingEmail ? 'Sending...' : 'Send Email OTP',
                    isLoading: _isSendingEmail,
                    onPressed: _isSendingEmail ? null : _sendEmailOtp,
                  )
                else if (_emailOtpSent && !_emailVerified) ...[
                  Pinput(
                    controller: _emailOtpController,
                    length: 6,
                    onCompleted: (_) => _verifyEmailOtp(),
                    errorPinTheme: PinTheme(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    text: _isVerifyingEmail
                        ? 'Verifying...'
                        : 'Verify Email OTP',
                    isLoading: _isVerifyingEmail,
                    onPressed: _isVerifyingEmail ? null : _verifyEmailOtp,
                  ),
                  if (_emailOtpError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _emailOtpError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ] else if (_emailVerified)
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Email Verified',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // ── Phone Verification Section ─────────────────────────────────
                Text('Phone: ${widget.identifier.phone}'),
                const SizedBox(height: 8),

                if (!_phoneOtpSent && !_phoneVerified)
                  AppButton(
                    text: _isSendingPhone ? 'Sending...' : 'Send Phone OTP',
                    isLoading: _isSendingPhone,
                    onPressed: _isSendingPhone ? null : _sendPhoneOtp,
                  )
                else if (_phoneOtpSent && !_phoneVerified) ...[
                  Pinput(
                    controller: _phoneOtpController,
                    length: 6,
                    onCompleted: (_) => _verifyPhoneOtp(),
                    errorPinTheme: PinTheme(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    text: _isVerifyingPhone
                        ? 'Verifying...'
                        : 'Verify Phone OTP',
                    isLoading: _isVerifyingPhone,
                    onPressed: _isVerifyingPhone ? null : _verifyPhoneOtp,
                  ),
                  if (_phoneOtpError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _phoneOtpError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ] else if (_phoneVerified)
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Phone Verified',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),

                const SizedBox(height: 40),

                // ── Save Button ─────────────────────────────────────────────────
                AppButton(
                  text: _isSaving ? 'Saving...' : 'Save Password & Continue',
                  isLoading: _isSaving,
                  onPressed: canSave ? _savePasswordAndLogin : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
