class HomeJob {
  final String jobId;
  final String jobTitle;
  final String workPlaceType;
  final String jobType;
  final num salaryFixed;
  final num salaryRangeFrom;
  final num salaryRangeTo;
  final String salaryType;
  final String currency;
  final String createdAt;
  final String companyName;
  final String logo;
  final String industry;

  HomeJob({
    required this.jobId,
    required this.jobTitle,
    required this.workPlaceType,
    required this.jobType,
    required this.salaryFixed,
    required this.salaryRangeFrom,
    required this.salaryRangeTo,
    required this.salaryType,
    required this.currency,
    required this.createdAt,
    required this.companyName,
    required this.logo,
    required this.industry,
  });

  factory HomeJob.fromJson(Map<String, dynamic> json) {
    num n(dynamic v) => (v is num) ? v : num.tryParse(v?.toString() ?? "0") ?? 0;

    return HomeJob(
      jobId: (json["jobId"] ?? "").toString(),
      jobTitle: (json["jobTitle"] ?? "").toString(),
      workPlaceType: (json["workPlaceType"] ?? "").toString(),
      jobType: (json["jobType"] ?? "").toString(),
      salaryFixed: n(json["salaryFixed"]),
      salaryRangeFrom: n(json["salaryRangeFrom"]),
      salaryRangeTo: n(json["salaryRangeTo"]),
      salaryType: (json["salaryType"] ?? "").toString(),
      currency: (json["currency"] ?? "").toString(),
      createdAt: (json["createdAt"] ?? "").toString(),
      companyName: (json["companyName"] ?? "").toString(),
      logo: (json["logo"] ?? "").toString(),
      industry: (json["industry"] ?? "").toString(),
    );
  }
}
