import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../data/otp_purpose.dart';
import '../../view_model/otp_view_model.dart';
import '../widgets/hutopia_scaled_screen.dart';
import '../widgets/hutopia_theme.dart';
import '../widgets/hutopia_primary_button.dart';

class OtpArgs {
  final String email;
  final OtpPurpose purpose;
  const OtpArgs({required this.email, required this.purpose});
}

class OtpVerificationView extends StatelessWidget {
  final OtpArgs args;
  const OtpVerificationView({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HutopiaTheme.bg,
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (_) => OtpViewModel(
            context.read<AuthRepository>(), // AuthRepository from Provider
            email: args.email,
            purpose: args.purpose,
          ),
          child: const _OtpBody(),
        ),
      ),
    );
  }
}

class _OtpBody extends StatelessWidget {
  const _OtpBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OtpViewModel>();
    final masked = _maskEmail(vm.email);

    return HutopiaScaledScreen(
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
            top: 240,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 26,
                  color: HutopiaTheme.title,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            top: 290,
            left: HutopiaTheme.sidePad,
            right: HutopiaTheme.sidePad,
            child: Column(
              children: [
                const Text(
                  'Enter the verification code we just sent\non your email address',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: HutopiaTheme.body, height: 1.35),
                ),
                const SizedBox(height: 8),
                Text(
                  masked,
                  style: const TextStyle(fontSize: 13, color: HutopiaTheme.body),
                ),
              ],
            ),
          ),

          Positioned(
            top: 410,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OtpBox(controller: vm.c1, autoFocus: true),
                const SizedBox(width: 16),
                _OtpBox(controller: vm.c2),
                const SizedBox(width: 16),
                _OtpBox(controller: vm.c3),
                const SizedBox(width: 16),
                _OtpBox(controller: vm.c4),
              ],
            ),
          ),

          if (vm.errorText != null)
            Positioned(
              top: 485,
              left: HutopiaTheme.sidePad,
              right: HutopiaTheme.sidePad,
              child: Center(
                child: Text(
                  vm.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ),

          Positioned(
            top: 520,
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
                    text: 'Verify',
                    onPressed: () => vm.verify(context),
                  ),
          ),

          Positioned(
            top: 600,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't received code? ",
                  style: TextStyle(fontSize: 12, color: HutopiaTheme.body),
                ),
                GestureDetector(
                  onTap: () => vm.resend(context),
                  child: const Text(
                    'Resend',
                    style: TextStyle(
                      fontSize: 12,
                      color: HutopiaTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '***@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;

  const _OtpBox({required this.controller, this.autoFocus = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: HutopiaTheme.primary, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: HutopiaTheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
