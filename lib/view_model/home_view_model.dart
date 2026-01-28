import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repo);

  final AuthRepository _repo;

  Future<void> signOut(BuildContext context) async {
    await _repo.signOut();
  }
}
