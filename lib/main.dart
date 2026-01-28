import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/auth_repository.dart';
import 'view/pages/auth_view.dart';

void main() {
  runApp(const HutopiaApp());
}
class HutopiaApp extends StatelessWidget {
  const HutopiaApp({super.key});
  @override
  Widget build(BuildContext context) {
    const baseUrl = 'https://mannuel-candidate-api-dev.myviva.net';
    return Provider<AuthRepository>(
      create: (_) => ApiAuthRepository(baseUrl: baseUrl),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hutopia',
        home: AuthView(),
      ),
    );
  }
}
