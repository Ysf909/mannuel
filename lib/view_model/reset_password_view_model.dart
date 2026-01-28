import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../view/pages/verified_view.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  ResetPasswordViewModel(this._repo, {required this.email});

  final AuthRepository _repo;
  final String email;

  final newPassController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscureNew = true;
  bool obscureConfirm = true;

  bool isLoading = false;
  String? errorText;

  void toggleNew() {
    obscureNew = !obscureNew;
    notifyListeners();
  }

  void toggleConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    errorText = null;
    final p1 = newPassController.text;
    final p2 = confirmController.text;

    if (p1.length < 6) {
      errorText = 'Password must be at least 6 characters.';
      notifyListeners();
      return;
    }
    if (p1 != p2) {
      errorText = 'Passwords do not match.';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _repo.resetPassword(email: email, newPassword: p1);
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const VerifiedView()),
      );
    } catch (_) {
      errorText = 'Could not reset password.';
    } finally {
      isLoading = false;
      if (context.mounted) notifyListeners();
    }
  }

  @override
  void dispose() {
    newPassController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}
