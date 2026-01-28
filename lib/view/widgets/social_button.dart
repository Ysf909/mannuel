import 'package:flutter/material.dart';
import 'hutopia_theme.dart';

/// Widget-only social button (no image assets).
/// Supports BOTH child: and icon: so older calls won't break.
class SocialButton extends StatelessWidget {
  final double size;
  final Widget child;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.size,
    required this.onTap,
    Widget? child,
    Widget? icon,
  }) : child = child ?? icon ?? const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: HutopiaTheme.fieldBg,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
