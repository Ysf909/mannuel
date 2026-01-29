import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mannuel/models/app_type_model.dart';
import 'package:mannuel/models/home_section_model.dart';
import 'package:mannuel/models/values_model.dart';

/// Simple domain exception to surface API errors to the UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => "AuthException: $message";
}

abstract class AuthRepository {
  /// Returns access token.
  Future<String> signIn({required String email, required String password});

  /// Sends OTP (sign up).
  Future<void> signUp({required String email, required String password});

  /// Verifies OTP and returns access token (if server returns it).
  Future<String> verifyOtp({required String email, required String otp});

  Future<void> sendResetCode({required String email});
  Future<void> resetPassword({required String email, required String newPassword});
  Future<void> signOut();

  // Dynamic Gender
  Future<int> getGenderTypeId(String accessToken);
  Future<List<AppValueModel>> getGenders(int typeId, String accessToken);

  // Step 3
  Future<void> registerPersonalInfos({
    required String email,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required String gender, // "Male" / "Female"
    required String accessToken,
  });
  Future<List<HomeSection>> getHomeSections({
  required String accessToken,
  required String search,
  required int pageNumber,
  required int pageSize,
});
  // Step 4
  Future<void> registerProfessionalInfos({
  required int professionalTitle,
  required List<String> preferedJobTitles,
  required List<int> preferedJobTypes,
  required String accessToken,
});


  // Step 4 Types
  Future<List<AppType>> getProfessionalTitles(String accessToken);
  Future<List<AppType>> getJobTitles(String accessToken);
  Future<List<AppType>> getJobTypes(String accessToken);
  Future<List<AppType>> getLocations(String accessToken);
}


/// API-backed implementation.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client(),
        _base = Uri.parse(baseUrl.endsWith("/") ? baseUrl : "$baseUrl/");

  final String baseUrl;
  final http.Client _client;
  final Uri _base;

  Uri _uri(String relativePath) {
    final clean =
        relativePath.startsWith("/") ? relativePath.substring(1) : relativePath;
    return _base.resolve(clean);
  }

  static String? _pickMessage(Map<String, dynamic> json) {
    for (final k
        in const ["message", "error", "title", "detail", "details", "msg"]) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      // sometimes "message" can be a list of strings
      if (v is List && v.isNotEmpty) {
        final first = v.first;
        if (first is String && first.trim().isNotEmpty) return first.trim();
      }
    }
    return null;
  }

  Map<String, dynamic> _decodeJsonSafe(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{"data": decoded};
    } catch (_) {
      return <String, dynamic>{"raw": raw};
    }
  }

  Never _throwHttp(String op, http.Response res) {
    final json = _decodeJsonSafe(res.body);
    final msg = _pickMessage(json) ?? "$op failed (${res.statusCode})";
    throw AuthException(msg);
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? extraHeaders,
  }) async {
    try {
      final res = await _client
          .post(
            _uri(path),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              ...?extraHeaders,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _throwHttp("POST $path", res);
      }
      return _decodeJsonSafe(res.body);
    } on SocketException {
      throw const AuthException("No internet connection.");
    } on HttpException {
      throw const AuthException("Network error. Please try again.");
    }
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    required Map<String, String> headers,
  }) async {
    try {
      final res =
          await _client.get(_uri(path), headers: headers).timeout(const Duration(seconds: 25));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        _throwHttp("GET $path", res);
      }
      return _decodeJsonSafe(res.body);
    } on SocketException {
      throw const AuthException("No internet connection.");
    } on HttpException {
      throw const AuthException("Network error. Please try again.");
    }
  }

  Map<String, String> _authHeaders(String accessToken) {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw const AuthException("Missing access token (Bearer)");
    }
    return {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ================= AUTH METHODS =================

@override
Future<List<HomeSection>> getHomeSections({
  required String accessToken,
  String search = "",
  int pageNumber = 1,
  int pageSize = 10,
}) async {
  final q = Uri.encodeQueryComponent(search);
  final json = await _getJson(
    "api/job/GetAllJobsHomepage?search=$q&pageNumber=$pageNumber&pageSize=$pageSize",
    headers: _authHeaders(accessToken),
  );

  final list = (json["data"] is List) ? (json["data"] as List) : <dynamic>[];
  return list
      .whereType<Map>()
      .map((e) => HomeSection.fromJson(e.cast<String, dynamic>()))
      .toList();
}

  @override
  Future<void> signUp({required String email, required String password}) async {
    // send OTP
    await _postJson("api/auth/createOTPToken", {"email": email.trim()});
  }

  @override
  Future<String> verifyOtp({required String email, required String otp}) async {
    // verify OTP (called "verifyPin" in your API)
    final json =
        await _postJson("api/auth/verifyPin", {"email": email.trim(), "otp": otp.trim()});

    // try common token fields
    for (final k in const ["accessToken", "token", "jwt"]) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    // sometimes token is nested in "data"
    final data = json["data"];
    if (data is Map<String, dynamic>) {
      for (final k in const ["accessToken", "token", "jwt"]) {
        final v = data[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }

    // if backend does not return token, let app continue but without auth calls
    throw const AuthException("OTP verified but no access token returned by server.");
  }

  @override
  Future<String> signIn({required String email, required String password}) async {
    final json = await _postJson("api/auth/login", {
      "email": email.trim(),
      "password": password,
    });

    for (final k in const ["accessToken", "token", "jwt"]) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    final data = json["data"];
    if (data is Map<String, dynamic>) {
      for (final k in const ["accessToken", "token", "jwt"]) {
        final v = data[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }

    throw const AuthException("Login succeeded but no access token returned by server.");
  }

  @override
  Future<void> sendResetCode({required String email}) async {
    throw UnimplementedError("sendResetCode is not yet implemented on server.");
  }

  @override
  Future<void> resetPassword(
      {required String email, required String newPassword}) async {
    throw UnimplementedError("resetPassword is not yet implemented on server.");
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  // ================= STEP 3 =================

  @override
  Future<void> registerPersonalInfos({
    required String email,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required String gender,
    required String accessToken,
  }) async {
    final token = accessToken.trim();
    if (token.isEmpty) throw const AuthException("Missing access token (Bearer)");

    final birth =
        "${birthDate.year.toString().padLeft(4, '0')}-"
        "${birthDate.month.toString().padLeft(2, '0')}-"
        "${birthDate.day.toString().padLeft(2, '0')}";

    // This matches the validator errors you saw:
    // - dob/dateOfBirth rejected
    // - gender must be a string
    await _postJson(
      "api/auth/RegisterPersonalInfos",
      {
        "email": email.trim(),
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
        "birthDate": birth,
        "gender": gender.trim(), // "Male"/"Female"
      },
      extraHeaders: {
        "Authorization": "Bearer $token",
      },
    );
  }

  // ================= STEP 4 =================
@override
Future<void> registerProfessionalInfos({
  required int professionalTitle,
  required List<String> preferedJobTitles, // ✅ strings
  required List<int> preferedJobTypes,
  required String accessToken,
}) async {
  final token = accessToken.trim();

  await _postJson(
    "api/auth/RegisterProfessionalInfos",
    {
      "professionalTitle": professionalTitle,
      "preferedJobTitles": jsonEncode(preferedJobTitles.map((e) => e.trim()).where((e) => e.isNotEmpty).toList()), // ✅ list<string>
      "preferedJobTypes": jsonEncode(preferedJobTypes),   // ✅ list<int>
    },
    extraHeaders: {"Authorization": "Bearer $token"},
  );
}


  

  // ================= STEP 4 TYPES =================

  Future<List<AppType>> _getTypes(String accessToken, int typeId) async {
    final json = await _getJson(
      'api/values/getAllValues?typeId=$typeId&search=&pageSize=50&pageNumber=1&language=en',
      headers: _authHeaders(accessToken),
    );

    final items = (json["data"] is List) ? (json["data"] as List) : <dynamic>[];
    return items
        .map((e) => AppType.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<List<AppType>> getProfessionalTitles(String accessToken) =>
      _getTypes(accessToken, 152);

  @override
  Future<List<AppType>> getJobTitles(String accessToken) =>
      _getTypes(accessToken, 143);

  @override
  Future<List<AppType>> getJobTypes(String accessToken) =>
      _getTypes(accessToken, 173);

  @override
  Future<List<AppType>> getLocations(String accessToken) =>
      _getTypes(accessToken, 107);

  // ================= DYNAMIC GENDER =================

  @override
  Future<int> getGenderTypeId(String accessToken) async {
    final json = await _getJson(
      'api/values/getAllValueTypes?pageSize=200&pageNumber=1',
      headers: _authHeaders(accessToken),
    );

    final List list = (json["data"] is List) ? (json["data"] as List) : <dynamic>[];

    final gender = list.cast<dynamic?>().firstWhere(
          (e) => e is Map && (e['name']?.toString() == 'Gender'),
          orElse: () => null,
        );
    if (gender == null) throw const AuthException('Gender type not found');

    final id = (gender as Map)['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    throw const AuthException("Invalid gender type id");
  }

  @override
  Future<List<AppValueModel>> getGenders(int typeId, String accessToken) async {
    final json = await _getJson(
      'api/values/getAllValues?typeId=$typeId&search=&pageSize=50&pageNumber=1&language=en',
      headers: _authHeaders(accessToken),
    );

    final items = (json["data"] is List) ? (json["data"] as List) : <dynamic>[];
    return items.map((e) => AppValueModel.fromJson(e)).toList();
  }
}




