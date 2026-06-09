import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../api/providers/central_server_api_client_provider.dart';
import '../../../shared/errors/result.dart';
import '../models/artist-response.dart';
import '../models/festival-info-response.dart';
import '../models/lineup-response.dart';
import '../models/point-of-interest-response.dart';
import '../models/stage-area.dart';
import '../models/stage-response.dart';

part 'stage_area_provider.g.dart';

@riverpod
StageAreaRepository stageAreaRepository(Ref ref) {
  return ApiStageAreaRepository(ref);
}

@Riverpod(keepAlive: true)
Future<FestivalArea> festivalAreaData(Ref ref) async {
  final repository = ref.watch(stageAreaRepositoryProvider);
  return repository.getFestivalArea();
}

abstract class StageAreaRepository {
  Future<FestivalArea> getFestivalArea();
}

class ApiStageAreaRepository implements StageAreaRepository {
  final Ref ref;
  final Random _random = Random(7);

  ApiStageAreaRepository(this.ref);

  @override
  Future<FestivalArea> getFestivalArea() async {
    final apiClient = ref.watch(centralServerApiClientProvider);

    final festivalInfoResult = await apiClient.getFestivalInfo();
    final stagesResult = await apiClient.getStages();
    final pointsOfInterestResult = await apiClient.getPointsOfInterest();
    final artistsResult = await apiClient.getArtists();
    final lineupResult = await apiClient.getLineup();

    if (festivalInfoResult is Failure<FestivalInfoResponse, Exception>) {
      throw festivalInfoResult.exception;
    }

    if (stagesResult is Failure<List<StageResponse>, Exception>) {
      throw stagesResult.exception;
    }

    if (pointsOfInterestResult is Failure<List<PointOfInterestResponse>, Exception>) {
      throw pointsOfInterestResult.exception;
    }

    if (artistsResult is Failure<List<ArtistResponse>, Exception>) {
      throw artistsResult.exception;
    }

    if (lineupResult is Failure<List<LineupResponse>, Exception>) {
      throw lineupResult.exception;
    }

    final festivalInfo =
        (festivalInfoResult as Success<FestivalInfoResponse, Exception>).value;

    final stagesResponse =
        (stagesResult as Success<List<StageResponse>, Exception>).value;

    final pointsOfInterestResponse =
        (pointsOfInterestResult as Success<List<PointOfInterestResponse>, Exception>).value;

    final artistsResponse =
        (artistsResult as Success<List<ArtistResponse>, Exception>).value;

    final lineupResponse =
        (lineupResult as Success<List<LineupResponse>, Exception>).value;

    final center = LatLng(
      festivalInfo.latitude,
      festivalInfo.longitude,
    );

    final stages = _createStages(center, stagesResponse);
    final pointsOfInterest = _createPointsOfInterest(pointsOfInterestResponse);
    final artists = _createArtists(artistsResponse);
    final lineup = _createLineup(lineupResponse);
    final festivalRadius = _festivalRadius(center, stages, pointsOfInterest);
    final festivalPoints = _createFestivalAreaPoints(
      center: center,
      radius: festivalRadius,
      stages: stages,
      pointsOfInterest: pointsOfInterest,
    );

    return FestivalArea(
      id: festivalInfo.id,
      name: festivalInfo.name,
      description: festivalInfo.description,
      location: center,
      color: Colors.blueAccent,
      points: festivalPoints,
      stages: stages,
      pointsOfInterest: pointsOfInterest,
      artists: artists,
      lineup: lineup,
    );
  }

  List<StageArea> _createStages(
      LatLng festivalCenter,
      List<StageResponse> stages,
      ) {
    final colors = [
      Colors.pinkAccent,
      Colors.deepPurpleAccent,
      Colors.orangeAccent,
      Colors.lightGreenAccent,
      Colors.cyanAccent,
      Colors.amberAccent,
      Colors.redAccent,
    ];

    return stages.asMap().entries.map((entry) {
      final index = entry.key;
      final stage = entry.value;
      final location = LatLng(stage.latitude, stage.longitude);

      return StageArea(
        id: stage.id,
        name: stage.name,
        location: location,
        capacity: stage.capacity,
        currentCrowd: stage.currentCrowd,
        overcrowded: stage.overcrowded,
        zoneCode: stage.zoneCode,
        color: colors[index % colors.length],
        points: _createOrganicAreaPoints(
          location,
          _stageRadius(festivalCenter, location),
          9,
        ),
      );
    }).toList();
  }

  List<PointOfInterest> _createPointsOfInterest(
      List<PointOfInterestResponse> pointsOfInterest,
      ) {
    return pointsOfInterest.map((pointOfInterest) {
      return PointOfInterest(
        id: pointOfInterest.id,
        name: pointOfInterest.name,
        type: pointOfInterest.type,
        description: pointOfInterest.description,
        location: LatLng(
          pointOfInterest.latitude,
          pointOfInterest.longitude,
        ),
        zoneCode: pointOfInterest.zoneCode,
        openingHours: pointOfInterest.openingHours,
      );
    }).toList();
  }

  List<FestivalArtist> _createArtists(List<ArtistResponse> artists) {
    return artists.map((artist) {
      return FestivalArtist(
        id: artist.id,
        name: artist.name,
        genre: artist.genre,
        bio: artist.bio,
        country: artist.country,
        imageUrl: artist.imageUrl,
      );
    }).toList();
  }

  List<FestivalLineupItem> _createLineup(List<LineupResponse> lineup) {
    final sortedLineup = [...lineup]..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    return sortedLineup.map((item) {
      return FestivalLineupItem(
        id: item.id,
        artistId: item.artistId,
        artistName: item.artistName,
        artistGenre: item.artistGenre,
        stageId: item.stageId,
        stageName: item.stageName,
        stageZoneCode: item.stageZoneCode,
        startsAt: item.startsAt,
        endsAt: item.endsAt,
        title: item.title,
        status: item.status,
      );
    }).toList();
  }

  double _festivalRadius(
      LatLng center,
      List<StageArea> stages,
      List<PointOfInterest> pointsOfInterest,
      ) {
    final distances = [
      ...stages.map((stage) => _coordinateDistance(center, stage.location)),
      ...pointsOfInterest.map((pointOfInterest) => _coordinateDistance(center, pointOfInterest.location)),
    ];

    if (distances.isEmpty) {
      return 0.006;
    }

    final maxDistance = distances.reduce(max);

    return max(
      0.006,
      maxDistance * 3 + 0.004,
    );
  }

  double _stageRadius(LatLng festivalCenter, LatLng stageCenter) {
    final distanceFromCenter = _coordinateDistance(festivalCenter, stageCenter);
    return max(0.00022, min(0.0005, distanceFromCenter * 0.32));
  }

  List<LatLng> _createFestivalAreaPoints({
    required LatLng center,
    required double radius,
    required List<StageArea> stages,
    required List<PointOfInterest> pointsOfInterest,
  }) {
    final points = _createOrganicAreaPoints(center, radius, 22);

    final requiredPoints = [
      ...stages.expand((stage) => stage.points),
      ...pointsOfInterest.map((pointOfInterest) => pointOfInterest.location),
    ];

    for (final requiredPoint in requiredPoints) {
      if (!_isPointInsidePolygon(requiredPoint, points)) {
        final angle = atan2(
          requiredPoint.longitude - center.longitude,
          requiredPoint.latitude - center.latitude,
        );

        points.add(
          LatLng(
            center.latitude + cos(angle) * radius * 1.18,
            center.longitude + sin(angle) * radius * 1.18,
          ),
        );
      }
    }

    points.sort((a, b) {
      final angleA = atan2(
        a.longitude - center.longitude,
        a.latitude - center.latitude,
      );

      final angleB = atan2(
        b.longitude - center.longitude,
        b.latitude - center.latitude,
      );

      return angleA.compareTo(angleB);
    });

    return points;
  }

  List<LatLng> _createOrganicAreaPoints(
      LatLng center,
      double radius,
      int sides,
      ) {
    final startAngle = _random.nextDouble() * 2 * pi;

    final angles = List.generate(sides, (index) {
      final baseAngle = startAngle + (2 * pi * index) / sides;
      final angleShift = (_random.nextDouble() - 0.5) * 0.35;

      return baseAngle + angleShift;
    })..sort();

    return angles.map((angle) {
      final radiusVariation = 0.65 + _random.nextDouble() * 0.7;
      final latitudeStretch = 0.9 + _random.nextDouble() * 0.22;
      final longitudeStretch = 0.9 + _random.nextDouble() * 0.22;

      return LatLng(
        center.latitude +
            cos(angle) * radius * radiusVariation * latitudeStretch,
        center.longitude +
            sin(angle) * radius * radiusVariation * longitudeStretch,
      );
    }).toList();
  }

  bool _isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    var inside = false;

    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].latitude;
      final yi = polygon[i].longitude;
      final xj = polygon[j].latitude;
      final yj = polygon[j].longitude;

      final intersects = ((yi > point.longitude) != (yj > point.longitude)) &&
          (point.latitude <
              (xj - xi) *
                  (point.longitude - yi) /
                  ((yj - yi) == 0 ? 0.0000001 : yj - yi) +
                  xi);

      if (intersects) {
        inside = !inside;
      }
    }

    return inside;
  }

  double _coordinateDistance(LatLng a, LatLng b) {
    final latitudeDelta = a.latitude - b.latitude;
    final longitudeDelta = a.longitude - b.longitude;

    return sqrt(latitudeDelta * latitudeDelta + longitudeDelta * longitudeDelta);
  }
}