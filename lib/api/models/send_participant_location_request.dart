class SendParticipantLocationRequest {
  final String participantId;
  final int stageId;
  final double latitude;
  final double longitude;
  final String zoneCode;
  final String recordedAt;

  SendParticipantLocationRequest({
    required this.participantId,
    required this.stageId,
    required this.latitude,
    required this.longitude,
    required this.zoneCode,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
    'participantId': participantId,
    'stageId': stageId,
    'latitude': latitude,
    'longitude': longitude,
    'zoneCode': zoneCode,
    'recordedAt': recordedAt,
  };
}