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

    final stages = _createStages(stagesResponse);
    final pointsOfInterest = _createPointsOfInterest(pointsOfInterestResponse);
    final artists = _createArtists(artistsResponse);
    final lineup = _createLineup(lineupResponse);

    return FestivalArea(
      id: festivalInfo.id,
      name: festivalInfo.name,
      description: festivalInfo.description,
      location: center,
      radiusMeters: _festivalRadiusMeters(center, stages, pointsOfInterest),
      color: Colors.blueAccent,
      stages: stages,
      pointsOfInterest: pointsOfInterest,
      artists: artists,
      lineup: lineup,
    );
  }

  List<StageArea> _createStages(List<StageResponse> stages) {
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

      return StageArea(
        id: stage.id,
        name: stage.name,
        location: LatLng(stage.latitude, stage.longitude),
        capacity: stage.capacity,
        currentCrowd: stage.currentCrowd,
        overcrowded: stage.overcrowded,
        zoneCode: stage.zoneCode,
        radiusMeters: 20,
        color: colors[index % colors.length],
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

  double _festivalRadiusMeters(
      LatLng center,
      List<StageArea> stages,
      List<PointOfInterest> pointsOfInterest,
      ) {
    final distances = [
      ...stages.map((stage) => _distanceMeters(center, stage.location) + stage.radiusMeters),
      ...pointsOfInterest.map((point) => _distanceMeters(center, point.location) + 20),
    ];

    if (distances.isEmpty) {
      return 160;
    }

    return max(160, distances.reduce(max) + 90);
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;

    final dLat = _degreesToRadians(b.latitude - a.latitude);
    final dLng = _degreesToRadians(b.longitude - a.longitude);

    final lat1 = _degreesToRadians(a.latitude);
    final lat2 = _degreesToRadians(b.latitude);

    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

    return 2 * earthRadius * atan2(sqrt(h), sqrt(1 - h));
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}