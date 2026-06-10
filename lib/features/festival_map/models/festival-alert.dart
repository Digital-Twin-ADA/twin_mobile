class FestivalAlert {
  final int id;
  final int stageId;
  final String type;
  final String message;
  final String severity;
  final DateTime createdAt;
  final bool resolved;
  final DateTime? resolvedAt;

  const FestivalAlert({
    required this.id,
    required this.stageId,
    required this.type,
    required this.message,
    required this.severity,
    required this.createdAt,
    required this.resolved,
    required this.resolvedAt,
  });

  factory FestivalAlert.fromJson(Map<String, dynamic> json) {
    return FestivalAlert(
      id: json['id'] as int,
      stageId: json['stageId'] as int,
      type: json['type'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolved: json['resolved'] as bool,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );
  }
}