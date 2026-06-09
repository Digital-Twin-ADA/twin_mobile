class PointOfInterestResponse {
  final int id;
  final String name;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final String? zoneCode;
  final String openingHours;

  const PointOfInterestResponse({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.zoneCode,
    required this.openingHours,
  });

  factory PointOfInterestResponse.fromJson(Map<String, dynamic> json) {
    return PointOfInterestResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoneCode: json['zoneCode'] as String?,
      openingHours: json['openingHours'] as String,
    );
  }
}