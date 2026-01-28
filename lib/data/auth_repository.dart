import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mannuel/models/app_type_model.dart';
import 'package:mannuel/models/values_model.dart';

/// Simple domain exception to surface API errors to the UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => "AuthException: $message";
}

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password}); // send OTP
  Future<void> sendResetCode({required String email});
  Future<void> verifyOtp({required String email, required String otp});
  Future<void> resetPassword({required String email, required String newPassword});
  Future<void> signOut();
  Future<int> getGenderTypeId(String accessToken);
  Future<List<AppValueModel>> getGenders(int typeId, String accessToken);

  // ================= STEP 4 =================
    @override
  Future<void> registerProfessionalInfos({
    required int professionalTitle,
    required int professionalJobTitle,
    required List<int> preferedJobTypes,
    required List<int> preferedJobLocations,
    required String accessToken,
  }) async {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw const AuthException("Missing access token (Bearer)");
    }

    await _postJson(
      "api/auth/RegisterProfessionalInfos",
      {
        "professionalTitle": professionalTitle,
        "professionalJobTitle": professionalJobTitle,
        "preferedJobTypes": preferedJobTypes,
        "preferedJobLocations": preferedJobLocations,
      },
      extraHeaders: {
        "Authorization": "Bearer $token",
      },
    );
  }

    // ===== Step 4 Types =====
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
    final clean = relativePath.startsWith("/") ? relativePath.substring(1) : relativePath;
    return _base.resolve(clean);
  }

  Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body,
      {Map<String, String>? extraHeaders}) async {
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

    final raw = res.body;
    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(raw);
      json = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{"data": decoded};
    } catch (_) {
      json = <String, dynamic>{"raw": raw};
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json;
    }

    throw AuthException(_pickMessage(json) ?? "Request failed (${res.statusCode})");
  }

  static String? _pickMessage(Map<String, dynamic> json) {
    for (final k in const ["message", "error", "title", "detail", "details", "msg"]) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  // ================= AUTH METHODS =================

  @override
  Future<void> signUp({required String email, required String password}) async {
    // send OTP
    await _postJson("api/auth/createOTPToken", {"email": email.trim()});
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    // verify OTP (called "verifyPin" in your API)
    await _postJson("api/auth/verifyPin", {"email": email.trim(), "otp": otp.trim()});
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    // Register or login personal info
    await _postJson("api/auth/RegisterPersonalInfos", {
      "email": email.trim(),
      "password": password,
    });
  }

  @override
  Future<void> sendResetCode({required String email}) async {
    // Implement if your backend has a reset endpoint
    throw UnimplementedError("sendResetCode is not yet implemented on server.");
  }

  @override
  Future<void> resetPassword({required String email, required String newPassword}) async {
    // Implement if your backend has a reset endpoint
    throw UnimplementedError("resetPassword is not yet implemented on server.");
  }

  @override
  Future<void> signOut() async {
    // Usually just clear tokens client-side
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }
    // ===== Step 4 Types =====

  @override
  Future<List<AppType>> getProfessionalTitles(String accessToken) async {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw const AuthException("Missing access token (Bearer)");
    }

    const url = 'api/values/getAllValues?typeId=152&search=&pageSize=50&pageNumber=1&language=en';
    final res = await _client.get(
      _uri(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final decoded = jsonDecode(res.body);
    final items = (decoded is Map && decoded['data'] is List)
        ? decoded['data'] as List
        : (decoded is List ? decoded : <dynamic>[]);

    return items.map((e) => AppType.fromJson(e as Map<String, dynamic>)).toList();
  }



  @override
  Future<List<AppType>> getJobTitles(String accessToken) async {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw const AuthException("Missing access token (Bearer)");
    }

    const url = 'api/values/getAllValues?typeId=143&search=&pageSize=50&pageNumber=1&language=en';
    final res = await _client.get(
      _uri(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final decoded = jsonDecode(res.body);
    final items = (decoded is Map && decoded['data'] is List)
        ? decoded['data'] as List
        : (decoded is List ? decoded : <dynamic>[]);

    return items.map((e) => AppType.fromJson(e as Map<String, dynamic>)).toList();
  }



  @override
  Future<List<AppType>> getJobTypes(String accessToken) async {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw const AuthException("Missing access token (Bearer)");
    }

    const url = 'api/values/getAllValues?typeId=173&search=&pageSize=50&pageNumber=1&language=en';
    final res = await _client.get(
      _uri(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final decoded = jsonDecode(res.body);
    final items = (decoded is Map && decoded['data'] is List)
        ? decoded['data'] as List
        : (decoded is List ? decoded : <dynamic>[]);

    return items.map((e) => AppType.fromJson(e as Map<String, dynamic>)).toList();
  }



  @override
  Future<List<AppType>> getLocations(String accessToken) async {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw const AuthException("Missing access token (Bearer)");
    }

    const url = 'api/values/getAllValues?typeId=107&search=&pageSize=50&pageNumber=1&language=en';
    final res = await _client.get(
      _uri(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final decoded = jsonDecode(res.body);
    final items = (decoded is Map && decoded['data'] is List)
        ? decoded['data'] as List
        : (decoded is List ? decoded : <dynamic>[]);

    return items.map((e) => AppType.fromJson(e as Map<String, dynamic>)).toList();
  }




  // ================= DYNAMIC GENDER =================

  @override
  Future<int> getGenderTypeId(String accessToken) async {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw const AuthException("Missing access token (Bearer)");
    }

    final res = await _client.get(
      _uri('api/values/getAllValueTypes'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final decoded = jsonDecode(res.body);
    final List list = (decoded is Map && decoded['data'] is List)
        ? decoded['data'] as List
        : (decoded is List ? decoded : <dynamic>[]);

    final gender = list.cast<dynamic?>().firstWhere(
          (e) => e is Map && e['name'] == 'Gender',
          orElse: () => null,
        );
    if (gender == null) throw Exception('Gender type not found');

    return (gender as Map)['id'] as int;
  }


  @override
  Future<List<AppValueModel>> getGenders(int typeId, String accessToken) async {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw const AuthException("Missing access token (Bearer)");
    }

    final res = await _client.get(
      _uri('api/values/getAllValues?typeId=$typeId&search=&pageSize=10&pageNumber=1&language=en'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final decoded = jsonDecode(res.body);
    final items = (decoded is Map && decoded['data'] is List)
        ? decoded['data'] as List
        : (decoded is List ? decoded : <dynamic>[]);

    return items.map((e) => AppValueModel.fromJson(e)).toList();
  }


  // ================= STEP 4 (ADDED) =================

  @override
  Future<void> registerProfessionalInfos({
    required int professionalTitle,
    required int professionalJobTitle,
    required List<int> preferedJobTypes,
    required List<int> preferedJobLocations,
    required String accessToken,
  }) async {
  final token = accessToken.trim();
  if (token.isEmpty) {
    throw const AuthException("Missing access token (Bearer)");
  }
await _postJson(
      "api/auth/RegisterProfessionalInfos",
      {
        "professionalTitle": professionalTitle,
        "professionalJobTitle": professionalJobTitle,
        "preferedJobTypes": preferedJobTypes,
        "preferedJobLocations": preferedJobLocations,
      },
      extraHeaders: {
        "Authorization": "Bearer $accessToken",
      },
    );
  }
}











