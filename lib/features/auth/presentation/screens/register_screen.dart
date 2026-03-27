import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:society_management_app/features/society/screens/home_screen.dart';
import 'package:society_management_app/features/society/screens/society_status_screen.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

import '../../domain/entities/society_entity.dart';
import '../../../user/domain/entities/user_entity.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _societyController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailOtpController = TextEditingController();
  final _phoneOtpController = TextEditingController();

  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
  bool _phoneIsValid = false;

  bool _emailVerified = false;
  bool _phoneVerified = false;
  bool _emailOtpSent = false;
  bool _phoneOtpSent = false;

  // Inline field errors
  String? _emailError;
  String? _phoneError;
  String? _emailOtpError;
  String? _phoneOtpError;

  bool _obscurePassword = true;

  // Per-step loading flags (driven by granular BLoC states)
  bool _emailOtpSending = false;
  bool _emailOtpVerifying = false;
  bool _phoneOtpSending = false;
  bool _phoneOtpVerifying = false;

  // ─── Validators ────────────────────────────────────────────────

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // ─── Email OTP ─────────────────────────────────────────────────

  void _sendEmailOtp() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }

    setState(() => _emailError = null);
    context.read<AuthBloc>().add(SendEmailOtp(email));
  }

  void _verifyEmailOtp() {
    final otp = _emailOtpController.text.trim();
    if (otp.length < 6) {
      setState(() => _emailOtpError = 'Enter the 6-digit OTP');
      return;
    }
    setState(() => _emailOtpError = null);
    context.read<AuthBloc>().add(
      VerifyEmailOtp(email: _emailController.text.trim(), otp: otp),
    );
  }

  // ─── Phone OTP ─────────────────────────────────────────────────

  void _sendPhoneOtp() {
    final fullNumber = _phoneNumber.phoneNumber?.trim() ?? '';
    if (!_phoneIsValid) {
      setState(
        () => _phoneError = 'Enter a valid phone number with country code',
      );
      return;
    }
    setState(() => _phoneError = null);
    print("sending otp");
    // Send full E.164 number e.g. +919876543210
    context.read<AuthBloc>().add(SendPhoneOtp(fullNumber));
  }

  void _verifyPhoneOtp() {
    final otp = _phoneOtpController.text.trim();
    if (otp.length < 6) {
      setState(() => _phoneOtpError = 'Enter the 6-digit OTP');
      return;
    }
    setState(() => _phoneOtpError = null);
    final fullNumber =
        _phoneNumber.phoneNumber?.trim() ?? _phoneController.text.trim();
    context.read<AuthBloc>().add(VerifyPhoneOtp(phone: fullNumber, otp: otp));
  }

  // ─── Submit ────────────────────────────────────────────────────

  void _submit() {
    bool hasError = false;

    if (!_emailVerified) {
      setState(() => _emailError = 'Please verify your email first');
      hasError = true;
    }

    if (!_phoneVerified) {
      setState(() => _phoneError = 'Please verify your phone number first');
      hasError = true;
    }

    if (!_formKey.currentState!.validate() || hasError) return;

    final society = SocietyEntity(
      id: 0,
      name: _societyController.text.trim(),
      address: _addressController.text.trim(),
      created_at: DateTime.now(),
      status: 'pending',
      description: '',
      adminId: 0,
    );

    final admin = UserEntity(
      id: 0,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneNumber.phoneNumber?.trim() ?? _phoneController.text.trim(),
      password: _passwordController.text,
      society_id: 0,
      role: 'admin',
      created_at: DateTime.now(),
      status: 'active',
    );

    context.read<AuthBloc>().add(
      CreateNewSociety(societyEntity: society, userEntity: admin),
    );
  }

  @override
  void dispose() {
    _societyController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailOtpController.dispose();
    _phoneOtpController.dispose();
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Register Society'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // ── Email OTP send ──────────────────────────────────────
          if (state is EmailOtpSending) {
            setState(() => _emailOtpSending = true);
          }
          if (state is EmailOtpSendingSuccess) {
            setState(() {
              _emailOtpSending = false;
              _emailOtpSent = true;
            });
          }
          if (state is EmailOtpSendingFailure) {
            setState(() {
              _emailOtpSending = false;
              _emailError = state.message;
            });
          }

          // ── Email OTP verify ────────────────────────────────────
          if (state is EmailOtpVerifying) {
            setState(() => _emailOtpVerifying = true);
          }
          if (state is EmailOtpVerifyingSuccess) {
            setState(() {
              _emailOtpVerifying = false;
              _emailVerified = true;
              _emailOtpError = null;
              _emailError = null;
            });
          }
          if (state is EmailOtpVerifyingFailure) {
            setState(() {
              _emailOtpVerifying = false;
              _emailOtpError = state.message;
            });
          }

          // ── Phone OTP send ──────────────────────────────────────
          if (state is PhoneOtpSending) {
            setState(() => _phoneOtpSending = true);
          }
          if (state is PhoneOtpSendingSuccess) {
            setState(() {
              _phoneOtpSending = false;
              _phoneOtpSent = true;
            });
          }
          if (state is PhoneOtpSendingFailure) {
            setState(() {
              _phoneOtpSending = false;
              _phoneError = state.message;
            });
          }

          // ── Phone OTP verify ────────────────────────────────────
          if (state is PhoneOtpVerifying) {
            setState(() => _phoneOtpVerifying = true);
          }
          if (state is PhoneOtpVerifyingSuccess) {
            setState(() {
              _phoneOtpVerifying = false;
              _phoneVerified = true;
              _phoneOtpError = null;
              _phoneError = null;
            });
          }
          if (state is PhoneOtpVerifyingFailure) {
            setState(() {
              _phoneOtpVerifying = false;
              _phoneOtpError = state.message;
            });
          }

          // ── Society creation ────────────────────────────────────
          if (state is CreateSocietyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: colorScheme.errorContainer,
                showCloseIcon: true,
              ),
            );
          }

          if (state is CreateSocietySuccess || state is Authenticated) {
            late UserEntity user;
            SocietyEntity? society;

            if (state is CreateSocietySuccess) {
              user = state.user;
              society = state.society;
            } else if (state is Authenticated) {
              user = state.user;
              society = state.society;
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SocietyStatusScreen(user: user, society: society),
              ),
            );
          }
        },
        builder: (context, state) {
          final isCreatingLoading = state is CreateSocietyLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Society Details Section ──────────────────────
                  _SectionHeader(
                    icon: Icons.apartment_rounded,
                    title: 'Society Details',
                    subtitle: 'Basic info about your housing society',
                  ),
                  const SizedBox(height: 14),
                  _FormCard(
                    children: [
                      AppTextField(
                        controller: _societyController,
                        label: 'Society Name',
                        prefixIcon: const Icon(
                          Icons.business_rounded,
                          size: 20,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Society name is required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _addressController,
                        label: 'Address',
                        maxLines: 2,
                        prefixIcon: const Icon(
                          Icons.location_on_rounded,
                          size: 20,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Address is required'
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Admin Details Section ─────────────────────────
                  _SectionHeader(
                    icon: Icons.person_rounded,
                    title: 'Admin Details',
                    subtitle: 'Your personal account information',
                  ),
                  const SizedBox(height: 14),
                  _FormCard(
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: const Icon(Icons.badge_rounded, size: 20),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // ── Email + OTP ──────────────────────────────
                      _VerifiableField(
                        field: AppTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          enabled: !_emailVerified,
                          prefixIcon: const Icon(Icons.email_rounded, size: 20),
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                          validator: (v) {
                            if (_emailVerified) return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!_isValidEmail(v.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        isVerified: _emailVerified,
                        otpSent: _emailOtpSent,
                        isSendingOtp: _emailOtpSending,
                        onSendOtp: _sendEmailOtp,
                        sendLabel: 'Send OTP',
                        verifiedLabel: 'Verified ✓',
                      ),

                      if (_emailOtpSent && !_emailVerified) ...[
                        const SizedBox(height: 14),
                        _OtpInput(
                          controller: _emailOtpController,
                          label: 'Email OTP',
                          errorText: _emailOtpError,
                          isVerifying: _emailOtpVerifying,
                          onVerify: _verifyEmailOtp,
                        ),
                      ],

                      const SizedBox(height: 14),

                      // ── Phone + OTP ──────────────────────────────
                      _PhoneField(
                        phoneController: _phoneController,
                        initialValue: _phoneNumber,
                        isVerified: _phoneVerified,
                        phoneError: _phoneError,
                        isSendingOtp: _phoneOtpSending,
                        onInputChanged: (value) {
                          setState(() {
                            _phoneNumber = value;
                            if (_phoneError != null) _phoneError = null;
                          });
                        },
                        onInputValidated: (isValid) {
                          setState(() => _phoneIsValid = isValid);
                        },
                        onSendOtp: _sendPhoneOtp,
                      ),

                      if (_phoneOtpSent && !_phoneVerified) ...[
                        const SizedBox(height: 14),
                        _OtpInput(
                          controller: _phoneOtpController,
                          label: 'Phone OTP',
                          errorText: _phoneOtpError,
                          isVerifying: _phoneOtpVerifying,
                          onVerify: _verifyPhoneOtp,
                        ),
                      ],

                      const SizedBox(height: 14),

                      // ── Password ─────────────────────────────────
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Password is required';
                          if (v.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Submit ────────────────────────────────────────
                  AppButton(
                    text: 'Create Society',
                    isLoading: isCreatingLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Form Card ───────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─── Verifiable Field (email row with Send OTP / Verified badge) ─────────────

class _VerifiableField extends StatelessWidget {
  final Widget field;
  final bool isVerified;
  final bool otpSent;
  final bool isSendingOtp;
  final VoidCallback onSendOtp;
  final String sendLabel;
  final String verifiedLabel;

  const _VerifiableField({
    required this.field,
    required this.isVerified,
    required this.otpSent,
    required this.isSendingOtp,
    required this.onSendOtp,
    required this.sendLabel,
    required this.verifiedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: field),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: isVerified
                  ? _VerifiedBadge()
                  : SizedBox(
                      height: 50,
                      child: FilledButton.tonal(
                        onPressed: isSendingOtp ? null : onSendOtp,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: isSendingOtp
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : Text(
                                otpSent ? 'Resend' : sendLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── OTP Input Row ───────────────────────────────────────────────────────────

class _OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool isVerifying;
  final VoidCallback onVerify;

  const _OtpInput({
    required this.controller,
    required this.label,
    required this.errorText,
    required this.isVerifying,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final defaultTheme = PinTheme(
      width: 46,
      height: 52,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
      ),
    );

    final focusedTheme = defaultTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.primary, width: 1.8),
      ),
    );

    final errorTheme = defaultTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.error, width: 1.4),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Pinput(
                controller: controller,
                length: 6,
                defaultPinTheme: defaultTheme,
                focusedPinTheme: focusedTheme,
                errorPinTheme: errorTheme,
                forceErrorState: errorText != null,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: isVerifying ? null : onVerify,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: isVerifying
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 14,
                color: colorScheme.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.error,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Phone Field ─────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController phoneController;
  final PhoneNumber initialValue;
  final bool isVerified;
  final String? phoneError;
  final bool isSendingOtp;
  final void Function(PhoneNumber) onInputChanged;
  final void Function(bool) onInputValidated;
  final VoidCallback onSendOtp;

  const _PhoneField({
    required this.phoneController,
    required this.initialValue,
    required this.isVerified,
    required this.phoneError,
    required this.isSendingOtp,
    required this.onInputChanged,
    required this.onInputValidated,
    required this.onSendOtp,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isVerified
                          ? colorScheme.surfaceContainerLowest.withOpacity(0.5)
                          : colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: phoneError != null
                            ? colorScheme.error
                            : colorScheme.outline.withOpacity(0.4),
                        width: phoneError != null ? 1.4 : 1.0,
                      ),
                    ),
                    child: InternationalPhoneNumberInput(
                      onInputChanged: onInputChanged,
                      onInputValidated: onInputValidated,
                      initialValue: initialValue,
                      textFieldController: phoneController,

                      isEnabled: !isVerified,
                      errorMessage: '',
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        useEmoji: true,
                      ),
                      inputDecoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 14,
                        ),
                      ),
                      spaceBetweenSelectorAndTextField: 0,
                    ),
                  ),
                  if (phoneError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(
                        phoneError!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.error,
                          height: 1.3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: isVerified
                  ? const _VerifiedBadge()
                  : SizedBox(
                      height: 50,
                      child: FilledButton.tonal(
                        onPressed: isSendingOtp ? null : onSendOtp,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: isSendingOtp
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Verified Badge ──────────────────────────────────────────────────────────

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
