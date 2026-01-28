import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../view_model/auth_view_model.dart';
import '../widgets/hutopia_scaled_screen.dart';
import '../widgets/hutopia_text_field.dart';
import '../widgets/hutopia_primary_button.dart';
import '../widgets/hutopia_theme.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_button.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(context.read<AuthRepository>()),
      child: const _AuthBody(),
    );
  }
}

class _AuthBody extends StatelessWidget {
  const _AuthBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: HutopiaTheme.bg,
      body: SafeArea(
        child: HutopiaScaledScreen(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 104),
                const Center(
                  child: Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 16,
                      color: HutopiaTheme.body,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/auth/hutopia.png',
                    width: 191,
                    height: 51,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: HutopiaTheme.sidePad),
                  child: Text(
                    'Fill your details or continue with\nsocial media',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: HutopiaTheme.body,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Form fields
                _AuthForm(),

                const SizedBox(height: 30),
                // Social login
                const OrDivider(text: 'Or'),
                const SizedBox(height: 20),
                _SocialButtons(),

                const SizedBox(height: 30),
                // Toggle Sign In / Sign Up
                _ToggleAuthMode(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Column(
      children: [
        HutopiaTextField(
          width: HutopiaTheme.fieldW,
          height: HutopiaTheme.fieldH,
          hint: 'Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          controller: vm.emailController,
        ),
        const SizedBox(height: 16),
        HutopiaTextField(
          width: HutopiaTheme.fieldW,
          height: HutopiaTheme.fieldH,
          hint: 'Password',
          icon: Icons.lock_outline,
          controller: vm.passwordController,
          obscureText: vm.obscurePassword,
          suffix: IconButton(
            onPressed: vm.togglePasswordVisibility,
            icon: Icon(
              vm.obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: HutopiaTheme.hint,
            ),
          ),
        ),
        if (vm.mode == AuthMode.signUp) ...[
          const SizedBox(height: 16),
          HutopiaTextField(
            width: HutopiaTheme.fieldW,
            height: HutopiaTheme.fieldH,
            hint: 'Confirm Password',
            icon: Icons.lock_outline,
            controller: vm.confirmPasswordController,
            obscureText: vm.obscureConfirm,
            suffix: IconButton(
              onPressed: vm.toggleConfirmVisibility,
              icon: Icon(
                vm.obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: HutopiaTheme.hint,
              ),
            ),
          ),
        ],
        if (vm.errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            vm.errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],
        const SizedBox(height: 20),
        vm.isLoading
            ? const SizedBox(
                width: HutopiaTheme.btnW,
                height: HutopiaTheme.btnH,
                child: Center(child: CircularProgressIndicator()),
              )
            : HutopiaPrimaryButton(
                width: HutopiaTheme.btnW,
                height: HutopiaTheme.btnH,
                text: vm.mode == AuthMode.signUp ? 'Sign Up' : 'Sign In',
                onPressed: vm.isLoading ? null : () => vm.submit(context),
              ),
        if (vm.mode == AuthMode.signIn)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => vm.goForgotPassword(context),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 13,
                  color: HutopiaTheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialButton(
          size: HutopiaTheme.socialSize,
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Google (UI only)'))),
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: HutopiaTheme.title,
            ),
          ),
        ),
        const SizedBox(width: 40),
        SocialButton(
          size: HutopiaTheme.socialSize,
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Facebook (UI only)'))),
          child: const Icon(
            Icons.facebook,
            size: 26,
            color: Color(0xFF1877F2),
          ),
        ),
      ],
    );
  }
}

class _ToggleAuthMode extends StatelessWidget {
  const _ToggleAuthMode({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          vm.mode == AuthMode.signUp
              ? "Already have an account? "
              : "Don't have an account? ",
          style: const TextStyle(fontSize: 13, color: HutopiaTheme.body),
        ),
        GestureDetector(
          onTap: vm.toggleMode,
          child: Text(
            vm.mode == AuthMode.signUp ? "Sign in" : "Sign up",
            style: const TextStyle(
              fontSize: 13,
              color: HutopiaTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
