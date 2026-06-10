import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/festival-alert.dart';
import 'participant_location_sender_provider.dart';

part 'stage_alert_provider.g.dart';

const _stageAlertSockets = {
  1: 'wss://festival-manager-vijk.onrender.com/ws',
  2: 'wss://festival-manager-stage-2.onrender.com/ws',
  3: 'wss://festival-manager-stage-3.onrender.com/ws',
};

@riverpod
Stream<FestivalAlert> stageAlert(Ref ref) {
  final stageId = ref.watch(
    simulatedParticipantLocationStateProvider.select(
          (location) => location?.currentStage?.id,
    ),
  );

  final socketUrl = _stageAlertSockets[stageId];

  if (socketUrl == null) {
    return const Stream.empty();
  }

  final channel = WebSocketChannel.connect(Uri.parse(socketUrl));

  ref.onDispose(() {
    channel.sink.close();
  });

  return channel.stream
      .where((event) => event is String)
      .map((event) => jsonDecode(event as String))
      .where((json) => json is Map<String, dynamic>)
      .map((json) => FestivalAlert.fromJson(json as Map<String, dynamic>))
      .where((alert) => alert.stageId == stageId && !alert.resolved);
}