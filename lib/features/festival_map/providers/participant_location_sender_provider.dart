import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../api/models/send_manager_location_request.dart';
import '../../../api/models/send_participant_location_request.dart';
import '../../../api/providers/central_server_api_client_provider.dart';
import '../../../shared/errors/result.dart';
import '../models/stage-area.dart';
import 'participant_session_provider.dart';
import 'stage_area_provider.dart';

part 'participant_location_sender_provider.g.dart';

class SimulatedParticipantLocation {
  final LatLng position;
  final StageArea? currentStage;
  final StageArea? previousStage;
  final StageArea? targetStage;
  final bool moving;
  final double progress;

  const SimulatedParticipantLocation({
    required this.position,
    required this.currentStage,
    required this.previousStage,
    required this.targetStage,
    required this.moving,
    required this.progress,
  });
}

@Riverpod(keepAlive: true)
class SimulatedParticipantLocationState extends _$SimulatedParticipantLocationState {
  @override
  SimulatedParticipantLocation? build() {
    return null;
  }

  void setLocation(SimulatedParticipantLocation location) {
    state = location;
  }
}

@Riverpod(keepAlive: true)
ParticipantLocationSender participantLocationSender(Ref ref) {
  final sender = ParticipantLocationSender(ref);
  ref.onDispose(sender.stop);
  return sender;
}

class ParticipantLocationSender {
  final Ref ref;
  final Random _random = Random.secure();

  Timer? _timer;
  bool _isSendingCentralLocation = false;
  bool _isSendingManagerLocation = false;
  bool _isStarting = false;

  FestivalArea? _festivalArea;
  StageArea? _currentStage;
  StageArea? _previousStage;
  StageArea? _targetStage;
  LatLng? _position;

  DateTime _lastStageChange = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _movementStartedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCentralSentAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastManagerSentAt = DateTime.fromMillisecondsSinceEpoch(0);

  final Duration stayDuration = const Duration(seconds: 30);
  final Duration movementDuration = const Duration(seconds: 4);
  final Duration centralSendInterval = const Duration(seconds: 5);
  final Duration managerSendInterval = const Duration(seconds: 3);

  final Map<int, String> managerApiBaseAddresses = const {
    1: 'https://festival-manager-vijk.onrender.com/',
    2: 'https://festival-manager-stage-2.onrender.com/',
    3: 'https://festival-manager-stage-3.onrender.com/',
  };

  ParticipantLocationSender(this.ref);

  Future<void> start({
    Duration interval = const Duration(milliseconds: 350),
  }) async {
    if (_timer != null || _isStarting) {
      return;
    }

    _isStarting = true;

    try {
      _festivalArea = await ref.read(festivalAreaDataProvider.future);

      final stages = _festivalArea?.stages ?? [];

      if (stages.isEmpty) {
        return;
      }

      _currentStage ??= stages[_random.nextInt(stages.length)];
      _position ??= _randomPointInsideStage(_currentStage!);
      _lastStageChange = DateTime.now();

      _publish();

      log('ParticipantLocationSender started');

      await _sendCentralLocation();
      await _sendManagerLocation();

      _timer = Timer.periodic(interval, (_) async {
        _tick();
        await _sendCentralLocationIfNeeded();
        await _sendManagerLocationIfNeeded();
      });
    } finally {
      _isStarting = false;
    }
  }

  void stop() {
    log('ParticipantLocationSender stopped');
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final festivalArea = _festivalArea;

    if (festivalArea == null || festivalArea.stages.isEmpty) {
      return;
    }

    final now = DateTime.now();

    if (_targetStage == null &&
        now.difference(_lastStageChange) >= stayDuration &&
        festivalArea.stages.length > 1) {
      _previousStage = _currentStage;
      _targetStage = _randomDifferentStage(festivalArea.stages, _currentStage);
      _movementStartedAt = now;
    }

    if (_targetStage != null && _previousStage != null) {
      final elapsed = now.difference(_movementStartedAt).inMilliseconds;
      final total = movementDuration.inMilliseconds;
      final rawProgress = (elapsed / total).clamp(0.0, 1.0);
      final easedProgress = CurvesLike.easeInOutCubic(rawProgress);

      final start = _previousStage!.center;
      final end = _targetStage!.center;

      _position = LatLng(
        start.latitude + (end.latitude - start.latitude) * easedProgress,
        start.longitude + (end.longitude - start.longitude) * easedProgress,
      );

      if (rawProgress >= 1) {
        _currentStage = _targetStage;
        _position = _randomPointInsideStage(_currentStage!);
        _targetStage = null;
        _previousStage = null;
        _lastStageChange = now;
      }
    } else if (_currentStage != null) {
      _position ??= _randomPointInsideStage(_currentStage!);
    }

    _publish();
  }

  void _publish() {
    final position = _position;

    if (position == null || !ref.mounted) {
      return;
    }

    ref.read(simulatedParticipantLocationStateProvider.notifier).setLocation(
      SimulatedParticipantLocation(
        position: position,
        currentStage: _currentStage,
        previousStage: _previousStage,
        targetStage: _targetStage,
        moving: _targetStage != null,
        progress: _targetStage == null
            ? 0
            : (DateTime.now().difference(_movementStartedAt).inMilliseconds /
            movementDuration.inMilliseconds)
            .clamp(0.0, 1.0),
      ),
    );
  }

  Future<void> _sendCentralLocationIfNeeded() async {
    if (DateTime.now().difference(_lastCentralSentAt) < centralSendInterval) {
      return;
    }

    await _sendCentralLocation();
  }

  Future<void> _sendManagerLocationIfNeeded() async {
    if (DateTime.now().difference(_lastManagerSentAt) < managerSendInterval) {
      return;
    }

    await _sendManagerLocation();
  }

  Future<void> _sendCentralLocation() async {
    if (_isSendingCentralLocation) {
      return;
    }

    final position = _position;
    final stage = _currentStage ?? _targetStage;

    if (position == null || stage == null) {
      return;
    }

    _isSendingCentralLocation = true;

    try {
      final participantId = await ref.read(participantIdProvider.future);

      if (!ref.mounted) {
        return;
      }

      final apiClient = ref.read(centralServerApiClientProvider);

      final result = await apiClient.sendParticipantLocation(
        SendParticipantLocationRequest(
          participantId: participantId,
          stageId: stage.id,
          latitude: position.latitude,
          longitude: position.longitude,
          zoneCode: stage.zoneCode ?? '',
          recordedAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );

      _lastCentralSentAt = DateTime.now();

      log(
        'Central location sent: '
            '${position.latitude}, '
            '${position.longitude}, '
            'participantId=$participantId '
            'stage=${stage.name} '
            'success=${result is Success}',
      );
    } on Exception catch (e) {
      log('Error while sending central participant location $e');
    } finally {
      _isSendingCentralLocation = false;
    }
  }

  Future<void> _sendManagerLocation() async {
    if (_isSendingManagerLocation) {
      return;
    }

    final position = _position;
    final stage = _currentStage ?? _targetStage;

    if (position == null || stage == null) {
      return;
    }

    final baseAddress = managerApiBaseAddresses[stage.id];

    if (baseAddress == null) {
      log('No manager API configured for stage ${stage.id}');
      return;
    }

    _isSendingManagerLocation = true;

    try {
      final participantId = await ref.read(participantIdProvider.future);

      if (!ref.mounted) {
        return;
      }

      final apiClient = ref.read(centralServerApiClientProvider);

      final result = await apiClient.sendManagerLocation(
        baseAddress: baseAddress,
        request: SendManagerLocationRequest(
          participantId: participantId,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      _lastManagerSentAt = DateTime.now();

      log(
        'Manager location sent: '
            '${position.latitude}, '
            '${position.longitude}, '
            'participantId=$participantId '
            'stage=${stage.id} '
            'url=${baseAddress}api/locations '
            'success=${result is Success}',
      );
    } on Exception catch (e) {
      log('Error while sending manager participant location $e');
    } finally {
      _isSendingManagerLocation = false;
    }
  }

  StageArea _randomDifferentStage(List<StageArea> stages, StageArea? current) {
    final available = stages.where((stage) => stage.id != current?.id).toList();

    if (available.isEmpty) {
      return stages[_random.nextInt(stages.length)];
    }

    return available[_random.nextInt(available.length)];
  }

  LatLng _randomPointInsideStage(StageArea stage) {
    final radius = stage.radiusMeters * sqrt(_random.nextDouble()) * 0.75;
    final angle = _random.nextDouble() * 2 * pi;

    final latitudeOffset = (radius * cos(angle)) / 111320;
    final longitudeOffset =
        (radius * sin(angle)) / (111320 * cos(stage.location.latitude * pi / 180));

    return LatLng(
      stage.location.latitude + latitudeOffset,
      stage.location.longitude + longitudeOffset,
    );
  }
}

class CurvesLike {
  static double easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
  }
}