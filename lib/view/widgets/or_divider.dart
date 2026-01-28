import 'package:flutter/material.dart';
import 'hutopia_theme.dart';

class OrDivider extends StatelessWidget {
  final String text;
  const OrDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 60,
          child: Divider(thickness: 1, color: Color(0xFF3A3A3A)),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: HutopiaTheme.body),
        ),
        const SizedBox(width: 12),
        const SizedBox(
          width: 60,
          child: Divider(thickness: 1, color: Color(0xFF3A3A3A)),
        ),
      ],
    );
  }
}
