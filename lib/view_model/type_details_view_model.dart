import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mannuel/data/auth_repository.dart';
import 'package:mannuel/models/app_type_model.dart';

class ProfessionalDetailsVM extends ChangeNotifier {
  final AuthRepository repo;
  final String accessToken;

  ProfessionalDetailsVM(this.repo, {required this.accessToken});

  // ====== Loaded options from API ======
  List<AppType> professionalTitles = [];
  List<AppType> jobTitles = [];
  List<AppType> jobTypes = [];     // typeId = 173
  List<AppType> locations = [];    // typeId = 107

  // ====== Selected values (IDs only) ======
  int? professionalTitle;       // from 152 values
  int? professionalJobTitle;    // from 143 values
  final List<int> preferredJobTypes = [];
  final List<int> preferredJobLocations = [];

  
  void setProfessionalTitle(int? id) {
    professionalTitle = id;
    notifyListeners();
  }

  void setProfessionalJobTitle(int? id) {
    professionalJobTitle = id;
    notifyListeners();
  }
bool isLoading = true;
  String? errorMessage;

  // Find "Remote" ID dynamically from API data (typeId 173)
  int? get _remoteId {
    for (final t in jobTypes) {
      if (t.value.trim().toLowerCase() == 'remote') return t.id;
    }
    return null;
  }

  // If ONLY Remote is selected -> we can hide physical locations
  bool get isRemoteOnly {
    final rid = _remoteId;
    if (rid == null) return false;
    return preferredJobTypes.length == 1 && preferredJobTypes.contains(rid);
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      professionalTitles = await repo.getProfessionalTitles(accessToken); // 152
      jobTitles = await repo.getJobTitles(accessToken);                   // 143
      jobTypes = await repo.getJobTypes(accessToken);                     // 173
      locations = await repo.getLocations(accessToken);                   // 107
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("❌ ProfessionalDetailsVM.load failed: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleJobType(int id) {
    if (preferredJobTypes.contains(id)) {
      preferredJobTypes.remove(id);
    } else {
      preferredJobTypes.add(id);
    }

    // If remote-only became true, clear physical locations (optional but clean)
    if (isRemoteOnly) {
      preferredJobLocations.clear();
    }

    notifyListeners();
  }

  void toggleLocation(int id) {
    if (preferredJobLocations.contains(id)) {
      preferredJobLocations.remove(id);
    } else {
      preferredJobLocations.add(id);
    }
    notifyListeners();
  }

  String get selectedLocationsLabel {
    if (preferredJobLocations.isEmpty) return "Select location";
    final selected = locations
        .where((l) => preferredJobLocations.contains(l.id))
        .map((e) => e.value)
        .toList();
    return selected.join(", ");
  }

  Future<void> submit() async {
    if (professionalTitle == null) {
      throw Exception("Please select professional title");
    }
    if (professionalJobTitle == null) {
      throw Exception("Please select job title");
    }
    if (preferredJobTypes.isEmpty) {
      throw Exception("Please select at least one job type");
    }

    // If not remote-only, require at least one location
    if (!isRemoteOnly && preferredJobLocations.isEmpty) {
      throw Exception("Please select at least one location");
    }

    await repo.registerProfessionalInfos(
      professionalTitle: professionalTitle!,
      professionalJobTitle: professionalJobTitle!,
      preferedJobTypes: preferredJobTypes,
      preferedJobLocations: preferredJobLocations,
      accessToken: accessToken,
    );
  }
}


