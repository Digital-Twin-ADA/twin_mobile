class LineupResponse {
  final int id;
  final int artistId;
  final String artistName;
  final String artistGenre;
  final int stageId;
  final String stageName;
  final String? stageZoneCode;
  final DateTime startsAt;
  final DateTime endsAt;
  final String title;
  final String status;

  const LineupResponse({
    required this.id,
    required this.artistId,
    required this.artistName,
    required this.artistGenre,
    required this.stageId,
    required this.stageName,
    required this.stageZoneCode,
    required this.startsAt,
    required this.endsAt,
    required this.title,
    required this.status,
  });

  factory LineupResponse.fromJson(Map<String, dynamic> json) {
    return LineupResponse(
      id: json['id'] as int,
      artistId: json['artistId'] as int,
      artistName: json['artistName'] as String,
      artistGenre: json['artistGenre'] as String,
      stageId: json['stageId'] as int,
      stageName: json['stageName'] as String,
      stageZoneCode: json['stageZoneCode'] as String?,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      title: json['title'] as String,
      status: json['status'] as String,
    );
  }
}