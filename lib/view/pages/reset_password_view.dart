import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../view_model/reset_password_view_model.dart';
import '../widgets/hutopia_scaled_screen.dart';
import '../widgets/hutopia_theme.dart';
import '../widgets/hutopia_text_field.dart';
import '../widgets/hutopia_primary_button.dart';

class ResetPasswordView extends StatelessWidget {
  final String email;
  const ResetPasswordView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(context.read<AuthRepository>(), email: email),
      child: const _ResetPasswordBody(),
    );
  }
}

class _ResetPasswordBody extends StatelessWidget {
  const _ResetPasswordBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResetPasswordViewModel>();

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
                top: 200,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                child: Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 28, color: HutopiaTheme.title, fontWeight: FontWeight.w700),
                ),
              ),
              const Positioned(
                top: 245,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                child: Text(
                  'Create a new password for your account.',
                  style: TextStyle(fontSize: 13, color: HutopiaTheme.body),
                ),
              ),

              Positioned(
                top: 330,
                left: HutopiaTheme.sidePad,
                child: HutopiaTextField(
                  width: HutopiaTheme.fieldW,
                  height: HutopiaTheme.fieldH,
                  hint: 'New Password',
                  icon: Icons.lock_outline,
                  controller: vm.newPassController,
                  obscureText: vm.obscureNew,
                  suffix: IconButton(
                    onPressed: vm.toggleNew,
                    icon: Icon(
                      vm.obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: HutopiaTheme.hint,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 406,
                left: HutopiaTheme.sidePad,
                child: HutopiaTextField(
                  width: HutopiaTheme.fieldW,
                  height: HutopiaTheme.fieldH,
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline,
                  controller: vm.confirmController,
                  obscureText: vm.obscureConfirm,
                  suffix: IconButton(
                    onPressed: vm.toggleConfirm,
                    icon: Icon(
                      vm.obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: HutopiaTheme.hint,
                    ),
                  ),
                ),
              ),

              if (vm.errorText != null)
                Positioned(
                  top: 480,
                  left: HutopiaTheme.sidePad,
                  right: HutopiaTheme.sidePad,
                  child: Text(vm.errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),

              Positioned(
                top: 550,
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
                        text: 'Save',
                        onPressed: () => vm.submit(context),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
