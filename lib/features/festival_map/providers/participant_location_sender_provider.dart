import 'dart:async';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../api/models/send_participant_location_request.dart';
import '../../../api/providers/central_server_api_client_provider.dart';
import '../../../shared/errors/result.dart';
import 'participant_session_provider.dart';

part 'participant_location_sender_provider.g.dart';

@Riverpod(keepAlive: true)
ParticipantLocationSender participantLocationSender(Ref ref) {
  final sender = ParticipantLocationSender(ref);
  ref.onDispose(sender.stop);
  return sender;
}

class ParticipantLocationSender {
  final Ref ref;
  Timer? _timer;
  bool _isSending = false;

  ParticipantLocationSender(this.ref);

  Future<void> start({
    Duration interval = const Duration(seconds: 5),
  }) async {
    if (_timer != null) {
      return;
    }

    log('ParticipantLocationSender started');

    await _sendCurrentLocation();

    _timer = Timer.periodic(interval, (_) async {
      await _sendCurrentLocation();
    });
  }

  void stop() {
    log('ParticipantLocationSender stopped');
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendCurrentLocation() async {
    if (_isSending) {
      return;
    }

    _isSending = true;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        log('Location service disabled');
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        log('Location permission denied');
        return;
      }

      if (!ref.mounted) {
        return;
      }

      final participantId = await ref.read(participantIdProvider.future);

      if (!ref.mounted) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!ref.mounted) {
        return;
      }

      final apiClient = ref.read(centralServerApiClientProvider);

      final result = await apiClient.sendParticipantLocation(
        SendParticipantLocationRequest(
          participantId: participantId,
          stageId: 1,
          latitude: position.latitude,
          longitude: position.longitude,
          zoneCode: 'A1',
          recordedAt: DateTime.now().toIso8601String(),
        ),
      );

      log(
        'Location sent: '
            '${position.latitude}, '
            '${position.longitude}, '
            'participantId=$participantId '
            'success=${result is Success}',
      );
    } on Exception catch (e) {
      log('Error while sending participant location $e');
    } finally {
      _isSending = false;
    }
  }
}