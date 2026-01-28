import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../view_model/forgot_password_view_model.dart';
import '../widgets/hutopia_scaled_screen.dart';
import '../widgets/hutopia_theme.dart';
import '../widgets/hutopia_text_field.dart';
import '../widgets/hutopia_primary_button.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(context.read<AuthRepository>()),
      child: const _ForgotPasswordBody(),
    );
  }
}

class _ForgotPasswordBody extends StatelessWidget {
  const _ForgotPasswordBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();

    return Scaffold(
      backgroundColor: HutopiaTheme.bg,
      body: SafeArea(
        child: HutopiaScaledScreen(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
              ),

              const Positioned(
                top: 180,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                child: Text(
                  'Forget Password?',
                  style: TextStyle(
                    fontSize: 28,
                    color: HutopiaTheme.title,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Positioned(
                top: 230,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                child: Text(
                  "Don't worry! occurs, please enter email\naddress linked with your account.",
                  style: TextStyle(fontSize: 13, color: HutopiaTheme.body, height: 1.35),
                ),
              ),

              Positioned(
                top: 330,
                left: HutopiaTheme.sidePad,
                child: HutopiaTextField(
                  width: HutopiaTheme.fieldW,
                  height: HutopiaTheme.fieldH,
                  hint: 'Email..',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  controller: vm.emailController,
                ),
              ),

              if (vm.errorText != null)
                Positioned(
                  top: 400,
                  left: HutopiaTheme.sidePad,
                  right: HutopiaTheme.sidePad,
                  child: Text(
                    vm.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              Positioned(
                top: 465,
                left: HutopiaTheme.sidePad,
                child: vm.isLoading
                    ? const SizedBox(
                        width: HutopiaTheme.btnW,
                        height: HutopiaTheme.btnH,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : HutopiaPrimaryButton(
                        width: HutopiaTheme.btnW,
                        height: HutopiaTheme.btnH,
                        text: 'Send Code',
                        onPressed: () => vm.sendCode(context),
                      ),
              ),

              Positioned(
                top: 540,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Back to Sign In',
                      style: TextStyle(
                        fontSize: 13,
                        color: HutopiaTheme.body,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
