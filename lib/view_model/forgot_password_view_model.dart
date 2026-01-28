import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../data/otp_purpose.dart';
import '../view/pages/otp_verification_view.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel(this._repo);

  final AuthRepository _repo;

  final emailController = TextEditingController();

  bool isLoading = false;
  String? errorText;

  Future<void> sendCode(BuildContext context) async {
    errorText = null;
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      errorText = 'Please enter a valid email.';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _repo.sendResetCode(email: email);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationView(
            args: OtpArgs(
              email: email,
              purpose: OtpPurpose.resetPassword,
            ),
          ),
        ),
      );
    } catch (_) {
      errorText = 'Could not send code. Try again.';
    } finally {
      isLoading = false;
      if (context.mounted) notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
