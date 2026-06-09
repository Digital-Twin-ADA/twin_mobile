import 'package:ada_project/features/festival_map/models/stage-response.dart';

class FestivalInfoResponse {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final List<StageResponse> stages;

  const FestivalInfoResponse({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.stages,
  });

  factory FestivalInfoResponse.fromJson(Map<String, dynamic> json) {
    return FestivalInfoResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      stages: (json['stages'] as List<dynamic>)
          .map((item) => StageResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}