import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mannuel/models/app_type_model.dart';

class TypeApiService {
  TypeApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _base = Uri.parse(baseUrl.endsWith("/") ? baseUrl : "$baseUrl/");

  final String baseUrl;
  final http.Client _client;
  final Uri _base;

  Uri _uri(String relativePath) {
    final clean = relativePath.startsWith("/") ? relativePath.substring(1) : relativePath;
    return _base.resolve(clean);
  }

  Future<List<AppType>> getTypes(int typeId) async {
    // Adjust path to match your backend. If your endpoint is:
    // api/values/getAllValues?typeId=...
    // then change this URL accordingly.
    final res = await _client.get(
      _uri("api/types/$typeId"),
      headers: {
        "Accept": "application/json",
      },
    );

    final data = jsonDecode(res.body);

    // If backend returns a raw list:
    if (data is List) {
      return data.map((e) => AppType.fromJson(e)).toList();
    }

    // If backend returns { data: [...] }:
    final items = (data is Map && data["data"] is List) ? data["data"] as List : <dynamic>[];
    return items.map((e) => AppType.fromJson(e)).toList();
  }
}