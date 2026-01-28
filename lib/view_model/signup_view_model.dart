import 'package:flutter/material.dart';
import 'package:mannuel/data/auth_repository.dart';
import 'package:mannuel/models/values_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SignupViewModel extends ChangeNotifier {
  final AuthRepository repo;
  SignupViewModel(this.repo);

  List<AppValueModel> genders = [];
  AppValueModel? selectedGender;
  bool isLoading = false;

Future<void> loadGenderFromApi(String accessToken) async {
  isLoading = true;
  notifyListeners();

  final typeId = await repo.getGenderTypeId(accessToken);
  genders = await repo.getGenders(typeId, accessToken);

  isLoading = false;
  notifyListeners();
}


  void selectGender(AppValueModel gender) {
    selectedGender = gender;
    saveGenderToPrefs(gender.id);
    notifyListeners();
  }

  Future<void> saveGenderToPrefs(int genderId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gender_value_id', genderId);
  }
}
