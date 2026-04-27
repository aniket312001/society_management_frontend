import 'package:flutter/material.dart';

import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:society_management_app/features/auth/presentation/screens/widgets/verify_badge.dart';

class PhoneLoginField extends StatelessWidget {
  final TextEditingController phoneController;
  final PhoneNumber initialValue;
  final bool isVerified;
  final String? phoneError;
  final bool isSendingOtp;
  final void Function(PhoneNumber) onInputChanged;
  final void Function(bool) onInputValidated;
  final VoidCallback onSendOtp;

  const PhoneLoginField({
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
                  ? const VerifiedBadge()
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
