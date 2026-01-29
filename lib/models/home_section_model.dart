class HomeSection {
  final String sectionTitle;
  final int sectionTypeId;
  final String sectionType; // "event" | "job"
  final String language;
  final String orientation; // "Horizontal" | "Vertical"
  final List<dynamic> dataRaw;

  HomeSection({
    required this.sectionTitle,
    required this.sectionTypeId,
    required this.sectionType,
    required this.language,
    required this.orientation,
    required this.dataRaw,
  });

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      sectionTitle: (json["sectionTitle"] ?? "").toString(),
      sectionTypeId: (json["sectionTypeId"] ?? 0) is int
          ? json["sectionTypeId"] as int
          : int.tryParse(json["sectionTypeId"].toString()) ?? 0,
      sectionType: (json["sectionType"] ?? "").toString(),
      language: (json["language"] ?? "").toString(),
      orientation: (json["orientation"] ?? "").toString(),
      dataRaw: (json["data"] is List) ? (json["data"] as List) : const [],
    );
  }
}
