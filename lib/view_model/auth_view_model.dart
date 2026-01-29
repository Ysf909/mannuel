import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../data/otp_purpose.dart';
import '../view/pages/forgot_password_view.dart';
import '../view/pages/otp_verification_view.dart';
import '../view/pages/home_view.dart';

enum AuthMode { signIn, signUp }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo);

  final AuthRepository _repo;

  AuthMode mode = AuthMode.signIn;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  bool isLoading = false;
  String? errorText;

  void toggleMode() {
    errorText = null;
    mode = mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  void goForgotPassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordView()),
    );
  }
Future<void> submit(BuildContext context) async {
  errorText = null;
  notifyListeners();

  final email = emailController.text.trim();
  final pass = passwordController.text.trim();

  if (email.isEmpty || !email.contains('@')) {
    errorText = 'Please enter a valid email.';
    notifyListeners();
    return;
  }

  if (pass.length < 6) {
    errorText = 'Password must be at least 6 characters.';
    notifyListeners();
    return;
  }

  if (mode == AuthMode.signUp &&
      confirmPasswordController.text.trim() != pass) {
    errorText = 'Passwords do not match.';
    notifyListeners();
    return;
  }

  isLoading = true;
  notifyListeners();

  try {
    if (mode == AuthMode.signIn) {
      await _repo.signIn(email: email, password: pass);
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeView(accessToken: '',)),
      );
    } else {
      await _repo.signUp(email: email, password: pass);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationView(
            args: OtpArgs(email: email, purpose: OtpPurpose.signUp),
          ),
        ),
      );
    }
  } catch (e) {
    // catch everything, including non-AuthException errors
    if (e is AuthException) {
      errorText = e.message;
    } else {
      // handle network / JSON errors gracefully
      errorText = 'Unable to connect. Please try again later.';
      print('Unexpected error in submit(): $e');
    }
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
