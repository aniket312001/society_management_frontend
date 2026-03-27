import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:society_management_app/core/widgets/app_button.dart';
import 'package:society_management_app/core/widgets/app_text_field.dart';
import 'package:society_management_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:society_management_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:society_management_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:society_management_app/features/auth/presentation/screens/register_screen.dart';
import 'package:society_management_app/features/society/screens/home_screen.dart';
import 'package:society_management_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:society_management_app/features/society/screens/society_status_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneOtpController = TextEditingController();

  // Phone number state
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
  bool _phoneIsValid = false;

  // UI state
  bool _isPhoneMode = false;
  bool _showCredentialField = false; // password or OTP field
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Reset error when user starts typing OTP
    _phoneOtpController.addListener(() {
      if (_errorMessage != null && _errorMessage!.contains('OTP')) {
        setState(() => _errorMessage = null);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneOtpController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Handlers
  // ──────────────────────────────────────────────

  void _checkUserIdentifier() {
    final identifier = _isPhoneMode
        ? _phoneNumber.phoneNumber?.trim() ?? ''
        : _emailController.text.trim();

    if (identifier.isEmpty) {
      setState(
        () =>
            _errorMessage = _isPhoneMode ? 'Enter phone number' : 'Enter email',
      );
      return;
    }

    if (_isPhoneMode && !_phoneIsValid) {
      setState(() => _errorMessage = 'Invalid phone number');
      return;
    }

    setState(() {
      _errorMessage = null;
      _showCredentialField = false;
    });

    context.read<AuthBloc>().add(
      CheckUserIdentifier(identifier, !_isPhoneMode),
    );
  }

  void _submitCredential() {
    if (_isPhoneMode) {
      _verifyPhoneOtp();
    } else {
      _loginWithEmail();
    }
  }

  void _verifyPhoneOtp() {
    final otp = _phoneOtpController.text.trim();

    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter 6-digit OTP');
      return;
    }

    final phone = _phoneNumber.phoneNumber ?? '';

    setState(() => _errorMessage = null);

    context.read<AuthBloc>().add(PhoneLoginEvent(phone: phone, otp: otp));
  }

  void _loginWithEmail() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter password');
      return;
    }

    setState(() => _errorMessage = null);

    context.read<AuthBloc>().add(
      EmailLoginEvent(email: email, password: password),
    );
  }

  // ──────────────────────────────────────────────
  // UI Building
  // ──────────────────────────────────────────────

  Widget _buildOtpField() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.blue, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      textStyle: const TextStyle(color: Colors.red, fontSize: 22),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final hasOtpError = _errorMessage != null && _errorMessage!.contains('OTP');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter 6-digit OTP",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Pinput(
          controller: _phoneOtpController,
          length: 6,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          errorPinTheme: errorPinTheme,
          forceErrorState: hasOtpError,
          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
          onCompleted: (_) => _verifyPhoneOtp(),
        ),
        if (hasOtpError) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? "Invalid or expired OTP",
            style: TextStyle(color: Colors.red[700], fontSize: 13),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is IdentifierNotFound) {
            setState(
              () => _errorMessage =
                  state.message ?? 'User not found. Please register first.',
            );

            print("nottt ound");
            return;
          }

          if (state is IdentifierRejected) {
            setState(
              () => _errorMessage = 'Account rejected. Contact support.',
            );
          }

          if (state is IdentifierActive) {
            setState(() {
              _showCredentialField = true;
              _errorMessage = null;
            });
          }

          if (state is IdentifierPending) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    OtpVerificationScreen(identifier: state.identifier),
              ),
            );
          }

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

          if (state is AuthError) {
            setState(() => _errorMessage = state.message);
          }

          // OTP specific failure
          if (state is PhoneOtpVerifyingFailure) {
            setState(() {
              _errorMessage = state.message ?? "Invalid or expired OTP";
            });
          }

          if (state is PhoneOtpVerifyingSuccess) {
            // Usually handled in Authenticated or another state
            setState(() => _errorMessage = null);
          }
        },
        builder: (context, state) {
          final isLoading =
              state is AuthLoading ||
              state is PhoneOtpVerifying ||
              state is EmailOtpVerifying;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.login_rounded, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email / Phone toggle
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Email')),
                    ButtonSegment(value: true, label: Text('Phone')),
                  ],
                  selected: {_isPhoneMode},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _isPhoneMode = newSelection.first;
                      _errorMessage = null;
                      _showCredentialField = false;
                      _phoneOtpController.clear();
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Identifier input
                _isPhoneMode
                    ? InternationalPhoneNumberInput(
                        onInputChanged: (value) {
                          _phoneNumber = value;
                          if (_phoneNumber.dialCode != value.dialCode ||
                              _phoneNumber.phoneNumber != value.phoneNumber ||
                              _phoneNumber.isoCode != value.isoCode) {
                            setState(() {
                              if (_errorMessage != null) _errorMessage = null;
                            });
                          }
                        },
                        onInputValidated: (isValid) =>
                            setState(() => _phoneIsValid = isValid),
                        initialValue: _phoneNumber,
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          useEmoji: true,
                        ),
                        inputDecoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: const OutlineInputBorder(),
                          errorText:
                              _errorMessage != null &&
                                  _isPhoneMode &&
                                  !_showCredentialField
                              ? _errorMessage
                              : null,
                        ),
                      )
                    : AppTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        autofillHints: const [AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        errorText: _errorMessage != null && !_isPhoneMode
                            ? _errorMessage
                            : null,
                      ),

                const SizedBox(height: 24),

                // Credential field (password or OTP)
                if (_showCredentialField) ...[
                  if (_isPhoneMode)
                    _buildOtpField()
                  else
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      errorText: _errorMessage != null && !_isPhoneMode
                          ? _errorMessage
                          : null,
                    ),
                  const SizedBox(height: 24),
                ],

                // Action button
                AppButton(
                  text: isLoading
                      ? 'Checking...'
                      : (_showCredentialField
                            ? (_isPhoneMode ? 'Verify OTP' : 'Login')
                            : 'Continue'),
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : (_showCredentialField
                            ? _submitCredential
                            : _checkUserIdentifier),
                ),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
