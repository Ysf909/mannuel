class HomeEvent {
  final String eventId;
  final String eventTitle;
  final String eventDescription;
  final String locationType;
  final String? venueName;
  final String? city;
  final String coverImage;
  final String startDate;
  final String endDate;

  HomeEvent({
    required this.eventId,
    required this.eventTitle,
    required this.eventDescription,
    required this.locationType,
    required this.venueName,
    required this.city,
    required this.coverImage,
    required this.startDate,
    required this.endDate,
  });

  factory HomeEvent.fromJson(Map<String, dynamic> json) {
    return HomeEvent(
      eventId: (json["eventId"] ?? "").toString(),
      eventTitle: (json["eventTitle"] ?? "").toString(),
      eventDescription: (json["eventDescription"] ?? "").toString(),
      locationType: (json["locationType"] ?? "").toString(),
      venueName: json["venueName"]?.toString(),
      city: json["city"]?.toString(),
      coverImage: (json["coverImage"] ?? "").toString(),
      startDate: (json["startDate"] ?? "").toString(),
      endDate: (json["endDate"] ?? "").toString(),
    );
  }
}
