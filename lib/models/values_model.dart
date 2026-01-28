class AppValueModel {
  final int id;
  final String value;

  AppValueModel({
    required this.id,
    required this.value,
  });

  factory AppValueModel.fromJson(Map<String, dynamic> json) {
    return AppValueModel(
      id: json['id'],
      value: json['value'],
    );
  }
}
