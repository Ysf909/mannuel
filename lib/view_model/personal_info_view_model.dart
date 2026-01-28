import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../view/pages/professional_details_view.dart';

enum Gender { male, female }

class PersonalInfoViewModel extends ChangeNotifier {
  PersonalInfoViewModel(this._repo, {required this.email});

  final AuthRepository _repo;
  final String email;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  int day = 1;
  int month = 1;
  int year = 2000;

  Gender gender = Gender.male;

  bool isLoading = false;
  String? errorText;

  void setGender(Gender g) {
    gender = g;
    notifyListeners();
  }

  void setDay(int v) {
    day = v;
    notifyListeners();
  }

  void setMonth(int v) {
    month = v;
    notifyListeners();
  }

  void setYear(int v) {
    year = v;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    errorText = null;
    if (firstNameController.text.trim().isEmpty) {
      errorText = 'Enter first name.';
      notifyListeners();
      return;
    }
    if (lastNameController.text.trim().isEmpty) {
      errorText = 'Enter last name.';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // no DB now - just simulate
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) {
          const token = String.fromEnvironment('ACCESS_TOKEN');
          return ProfessionalDetailsPage(accessToken: token, repo: _repo);
        }),
      );
    } catch (_) {
      errorText = 'Please try again.';
    } finally {
      isLoading = false;
      if (context.mounted) notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}
