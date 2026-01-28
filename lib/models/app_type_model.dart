// models/app_type.dart
class AppType {
  final int id;
  final String value;

  AppType({required this.id, required this.value});

  factory AppType.fromJson(Map<String, dynamic> json) {
    return AppType(
      id: json['id'],
      value: json['value'],
    );
  }
}
