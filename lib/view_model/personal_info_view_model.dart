import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../view/pages/professional_details_view.dart';

enum Gender { male, female }

class PersonalInfoViewModel extends ChangeNotifier {
  PersonalInfoViewModel(
    this._repo, {
    required this.email,
    required this.accessToken,
  });

  final AuthRepository _repo;
  final String email;
  final String accessToken;

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

  DateTime get _birthDate {
    final safeMonth = month.clamp(1, 12);
    final safeDay = day.clamp(1, 31);
    return DateTime(year, safeMonth, safeDay);
  }

  String get _genderString => (gender == Gender.male) ? "Male" : "Female";

  Future<void> submit(BuildContext context) async {
    errorText = null;

    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();

    if (first.isEmpty) {
      errorText = 'Enter first name.';
      notifyListeners();
      return;
    }
    if (last.isEmpty) {
      errorText = 'Enter last name.';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _repo.registerPersonalInfos(
        email: email,
        firstName: first,
        lastName: last,
        birthDate: _birthDate,
        gender: _genderString,
        accessToken: accessToken,
      );

      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              ProfessionalDetailsPage(accessToken: accessToken, repo: _repo),
        ),
      );
    } catch (e) {
      // If backend is inconsistent (validates string but DB expects int),
      // allow user to continue and show a warning.
      final msg = (e is AuthException) ? e.message : e.toString();
      if (msg.contains("p_gender_id") || msg.contains("Incorrect integer value")) {
        // show warning but proceed
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Saved partially (server gender mapping issue). You can continue.",
            ),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                ProfessionalDetailsPage(accessToken: accessToken, repo: _repo),
          ),
        );
        return;
      }

      errorText = (e is AuthException) ? e.message : 'Please try again.';
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
