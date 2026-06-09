import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'participant_session_provider.g.dart';

@riverpod
Future<String> participantId(Ref ref) async {
  final preferences = await SharedPreferences.getInstance();
  final existingParticipantId = preferences.getString('participant_id');

  if (existingParticipantId != null && existingParticipantId.isNotEmpty) {
    return existingParticipantId;
  }

  final random = Random.secure();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final suffix = List.generate(
    8,
        (_) => random.nextInt(16).toRadixString(16),
  ).join();

  final participantId = 'user-$timestamp-$suffix';

  await preferences.setString('participant_id', participantId);

  return participantId;
}