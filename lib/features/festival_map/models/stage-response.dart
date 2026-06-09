class StageResponse {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int capacity;
  final int currentCrowd;
  final bool overcrowded;
  final String? zoneCode;

  const StageResponse({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.currentCrowd,
    required this.overcrowded,
    required this.zoneCode,
  });

  factory StageResponse.fromJson(Map<String, dynamic> json) {
    return StageResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      capacity: json['capacity'] as int,
      currentCrowd: json['currentCrowd'] as int,
      overcrowded: json['overcrowded'] as bool,
      zoneCode: json['zoneCode'] as String?,
    );
  }
}