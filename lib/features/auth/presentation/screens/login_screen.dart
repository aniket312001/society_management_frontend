import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:society_management_app/core/widgets/app_button.dart';
import 'package:society_management_app/core/widgets/app_text_field.dart';
import 'package:society_management_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:society_management_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:society_management_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:society_management_app/features/society/screens/home_screen.dart';
import 'package:society_management_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:society_management_app/features/society/screens/society_status_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _credentialController = TextEditingController(); // password or OTP

  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
  bool _isPhoneMode = false;
  bool _phoneIsValid = false;

  String? _errorMessage;
  bool _isChecking = false;
  bool _showCredentialField = false; // controls password/OTP field visibility

  @override
  void dispose() {
    _identifierController.dispose();
    _credentialController.dispose();
    super.dispose();
  }

  void _checkUser() {
    final identifier = _isPhoneMode
        ? _phoneNumber.phoneNumber?.trim() ?? ''
        : _identifierController.text.trim();

    if (identifier.isEmpty) {
      setState(
        () => _errorMessage = _isPhoneMode
            ? 'Please enter your phone number'
            : 'Please enter your email number',
      );
      return;
    }

    if (_isPhoneMode && !_phoneIsValid) {
      setState(() => _errorMessage = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isChecking = true;
      _showCredentialField = false; // reset
    });

    context.read<AuthBloc>().add(
      CheckUserIdentifier(identifier, !_isPhoneMode),
    );
  }

  void _loginWithCredential() {
    final identifier = _isPhoneMode
        ? _phoneNumber.phoneNumber ?? ''
        : _identifierController.text.trim();

    final credential = _credentialController.text.trim();

    if (credential.isEmpty) {
      setState(() => _errorMessage = 'Please enter password or OTP');
      return;
    }

    setState(() => _errorMessage = null);

    // Decide login method
    if (_isPhoneMode) {
      context.read<AuthBloc>().add(
        VerifyPhoneOtp(phone: identifier, otp: credential),
      );
    } else {
      context.read<AuthBloc>().add(
        EmailLoginEvent(email: identifier, password: credential),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() => _isChecking = false);

          if (state is IdentifierNotFound) {
            setState(
              () => _errorMessage = 'User not found. Please register first.',
            );
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter your password or OTP')),
            );
          }

          if (state is IdentifierPending) {
            // Pending → go to OTP verification screen
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
        },
        builder: (context, state) {
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
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Identifier field (always visible)
                _isPhoneMode
                    ? InternationalPhoneNumberInput(
                        onInputChanged: (value) {
                          setState(() {
                            _phoneNumber = value;
                            if (_errorMessage != null) _errorMessage = null;
                          });
                        },
                        onInputValidated: (isValid) =>
                            setState(() => _phoneIsValid = isValid),
                        initialValue: _phoneNumber,
                        textFieldController: _identifierController,
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          useEmoji: true,
                        ),
                        inputDecoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: const OutlineInputBorder(),
                          errorText: _errorMessage,
                        ),
                      )
                    : AppTextField(
                        controller: _identifierController,
                        label: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.email_outlined),
                        errorText: _errorMessage,
                      ),

                const SizedBox(height: 24),

                // Conditional: Password / OTP field (only shown after identifier check = active)
                if (_showCredentialField) ...[
                  AppTextField(
                    controller: _credentialController,
                    label: _isPhoneMode ? 'Enter OTP' : 'Password',
                    obscureText: !_isPhoneMode, // show dots for password
                    // keyboardType: _isPhoneMode ? TextInputType.number : null,
                    prefixIcon: Icon(
                      _isPhoneMode ? Icons.lock_outline : Icons.password,
                    ),
                    errorText: _errorMessage,
                  ),
                  const SizedBox(height: 16),
                ],

                // Error message
                // if (_errorMessage != null && !_showCredentialField)
                //   Padding(
                //     padding: const EdgeInsets.only(bottom: 16),
                //     child: Text(
                //       _errorMessage!,
                //       style: TextStyle(
                //         color: Theme.of(context).colorScheme.error,
                //       ),
                //       textAlign: TextAlign.center,
                //     ),
                //   ),

                // Main Action Button
                AppButton(
                  text: _isChecking
                      ? 'Checking...'
                      : (_showCredentialField
                            ? (_isPhoneMode ? 'Verify OTP' : 'Login')
                            : 'Continue'),
                  isLoading: _isChecking,
                  onPressed: _isChecking
                      ? null
                      : (_showCredentialField
                            ? _loginWithCredential
                            : _checkUser),
                ),

                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
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
