class SendManagerLocationRequest {
  final String participantId;
  final double latitude;
  final double longitude;

  const SendManagerLocationRequest({
    required this.participantId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'participantId': participantId,
    'latitude': latitude,
    'longitude': longitude,
  };
}