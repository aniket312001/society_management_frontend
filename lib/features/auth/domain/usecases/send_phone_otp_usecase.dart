// send_phone_otp_usecase.dart
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class SendPhoneOtpUseCase {
  final AuthRepository repository;

  SendPhoneOtpUseCase(this.repository);

  Future<void> call(String phoneNumber) {
    // You could add formatting/validation here later
    // e.g. if (!phoneNumber.startsWith('+')) throw FormatException();
    return repository.sendPhoneOtp(phoneNumber);
  }
}
