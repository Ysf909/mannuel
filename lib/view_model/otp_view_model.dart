import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../data/otp_purpose.dart';
import '../view/pages/personal_info_view.dart';
import '../view/pages/reset_password_view.dart';

class OtpViewModel extends ChangeNotifier {
  OtpViewModel(this._repo, {required this.email, required this.purpose});

  final AuthRepository _repo;
  final String email;
  final OtpPurpose purpose;

  final c1 = TextEditingController();
  final c2 = TextEditingController();
  final c3 = TextEditingController();
  final c4 = TextEditingController();

  bool isLoading = false;
  String? errorText;

  String get otp => (c1.text + c2.text + c3.text + c4.text).trim();

  Future<void> verify(BuildContext context) async {
    errorText = null;
    if (otp.length != 4) {
      errorText = 'Enter the 4-digit code.';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _repo.verifyOtp(email: email, otp: otp);

      if (!context.mounted) return;

      if (purpose == OtpPurpose.signUp) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PersonalInfoView(email: email)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ResetPasswordView(email: email)),
        );
      }
    } catch (_) {
      errorText = 'Invalid code. Try again.';
    } finally {
      isLoading = false;
      if (context.mounted) notifyListeners();
    }
  }

  Future<void> resend(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resend (UI only)')),
    );
  }

  @override
  void dispose() {
    c1.dispose();
    c2.dispose();
    c3.dispose();
    c4.dispose();
    super.dispose();
  }
}