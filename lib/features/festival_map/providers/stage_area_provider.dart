import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/stage-area.dart';

part 'stage_area_provider.g.dart';

@riverpod
StageAreaRepository stageAreaRepository(Ref ref) {
  return MockStageAreaRepository();
}

@riverpod
class FestivalAreaData extends _$FestivalAreaData {
  FestivalArea? _cachedArea;

  @override
  Future<FestivalArea> build(LatLng center) async {
    if (_cachedArea != null) {
      return _cachedArea!;
    }

    final repository = ref.watch(stageAreaRepositoryProvider);
    final area = await repository.getFestivalArea(center);

    _cachedArea = area;

    return area;
  }
}

abstract class StageAreaRepository {
  Future<FestivalArea> getFestivalArea(LatLng center);
}

class MockStageAreaRepository implements StageAreaRepository {
  final Random _random = Random();

  @override
  Future<FestivalArea> getFestivalArea(LatLng center) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final festivalRadius = 0.0022;
    final festivalPoints = _createOrganicAreaPoints(center, festivalRadius, 10);
    final count = 2 + _random.nextInt(4);

    final names = [
      'Main Stage',
      'Sunset Stage',
      'Techno Dome',
      'Forest Stage',
      'Beach Arena',
    ];

    final colors = [
      Colors.pinkAccent,
      Colors.deepPurpleAccent,
      Colors.orangeAccent,
      Colors.lightGreenAccent,
      Colors.cyanAccent,
    ];

    final stages = List.generate(count, (index) {
      final angle = (2 * pi * index) / count + (_random.nextDouble() - 0.5) * 0.7;
      final distance = festivalRadius * (0.24 + _random.nextDouble() * 0.3);

      final areaCenter = LatLng(
        center.latitude + cos(angle) * distance,
        center.longitude + sin(angle) * distance,
      );

      return StageArea(
        id: 'stage_$index',
        name: names[index],
        color: colors[index],
        points: _createOrganicAreaPoints(
          areaCenter,
          festivalRadius * (0.18 + _random.nextDouble() * 0.08),
          7 + _random.nextInt(5),
        ),
      );
    });

    return FestivalArea(
      id: 'festival_area',
      name: 'Festival Grounds',
      color: Colors.blueAccent,
      points: festivalPoints,
      stages: stages,
    );
  }

  List<LatLng> _createOrganicAreaPoints(LatLng center, double radius, int sides) {
    final startAngle = _random.nextDouble() * 2 * pi;

    final angles = List.generate(sides, (index) {
      final baseAngle = startAngle + (2 * pi * index) / sides;
      final angleShift = (_random.nextDouble() - 0.5) * 0.45;

      return baseAngle + angleShift;
    })..sort();

    return angles.map((angle) {
      final radiusVariation = 0.55 + _random.nextDouble() * 0.75;
      final latitudeStretch = 0.75 + _random.nextDouble() * 0.45;
      final longitudeStretch = 0.75 + _random.nextDouble() * 0.45;

      return LatLng(
        center.latitude + cos(angle) * radius * radiusVariation * latitudeStretch,
        center.longitude + sin(angle) * radius * radiusVariation * longitudeStretch,
      );
    }).toList();
  }
}