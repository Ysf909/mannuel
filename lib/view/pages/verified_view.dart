import 'package:flutter/material.dart';
import 'auth_view.dart';
import 'home_view.dart';
import '../widgets/hutopia_theme.dart';
import '../widgets/hutopia_scaled_screen.dart';
import '../widgets/hutopia_primary_button.dart';

class VerifiedView extends StatelessWidget {
  const VerifiedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HutopiaTheme.bg,
      body: SafeArea(
        child: HutopiaScaledScreen(
          child: Stack(
            children: [
              const Positioned(
                top: 240,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(Icons.verified_rounded, size: 90, color: HutopiaTheme.primary),
                ),
              ),
              const Positioned(
                top: 350,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Verified',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: HutopiaTheme.title),
                  ),
                ),
              ),
              const Positioned(
                top: 400,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                child: Text(
                  'Your operation completed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: HutopiaTheme.body),
                ),
              ),

              Positioned(
                top: 520,
                left: HutopiaTheme.sidePad,
                child: HutopiaPrimaryButton(
                  width: HutopiaTheme.btnW,
                  height: HutopiaTheme.btnH,
                  text: 'Go Home',
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeView()),
                    (route) => false,
                  ),
                ),
              ),
              Positioned(
                top: 590,
                left: 0,
                right: 0,
                child: Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthView()),
                      (route) => false,
                    ),
                    child: const Text('Back to Auth'),
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
