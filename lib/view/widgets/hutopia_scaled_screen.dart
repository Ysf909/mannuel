import 'package:flutter/material.dart';
import 'hutopia_theme.dart';

/// Scales a 430x932 Figma design to any device width.
class HutopiaScaledScreen extends StatelessWidget {
  final Widget child;
  final bool scroll;

  const HutopiaScaledScreen({
    super.key,
    required this.child,
    this.scroll = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / HutopiaTheme.designW;

        final content = SizedBox(
          width: constraints.maxWidth,
          height: HutopiaTheme.designH * scale,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: HutopiaTheme.designW,
              height: HutopiaTheme.designH,
              child: child,
            ),
          ),
        );

        if (!scroll) return content;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: content,
        );
      },
    );
  }
}
