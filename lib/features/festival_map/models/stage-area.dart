import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StageArea {
  final int id;
  final String name;
  final LatLng location;
  final int capacity;
  final int currentCrowd;
  final bool overcrowded;
  final String? zoneCode;
  final double radiusMeters;
  final Color color;

  const StageArea({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.currentCrowd,
    required this.overcrowded,
    required this.zoneCode,
    required this.radiusMeters,
    required this.color,
  });

  LatLng get center => location;
}

class PointOfInterest {
  final int id;
  final String name;
  final String type;
  final String description;
  final LatLng location;
  final String? zoneCode;
  final String openingHours;

  const PointOfInterest({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.location,
    required this.zoneCode,
    required this.openingHours,
  });
}

class FestivalArtist {
  final int id;
  final String name;
  final String genre;
  final String bio;
  final String country;
  final String? imageUrl;

  const FestivalArtist({
    required this.id,
    required this.name,
    required this.genre,
    required this.bio,
    required this.country,
    required this.imageUrl,
  });
}

class FestivalLineupItem {
  final int id;
  final int artistId;
  final String artistName;
  final String artistGenre;
  final int stageId;
  final String stageName;
  final String? stageZoneCode;
  final DateTime startsAt;
  final DateTime endsAt;
  final String title;
  final String status;

  const FestivalLineupItem({
    required this.id,
    required this.artistId,
    required this.artistName,
    required this.artistGenre,
    required this.stageId,
    required this.stageName,
    required this.stageZoneCode,
    required this.startsAt,
    required this.endsAt,
    required this.title,
    required this.status,
  });
}

class FestivalArea {
  final int id;
  final String name;
  final String description;
  final LatLng location;
  final double radiusMeters;
  final Color color;
  final List<StageArea> stages;
  final List<PointOfInterest> pointsOfInterest;
  final List<FestivalArtist> artists;
  final List<FestivalLineupItem> lineup;

  const FestivalArea({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.radiusMeters,
    required this.color,
    required this.stages,
    required this.pointsOfInterest,
    required this.artists,
    required this.lineup,
  });

  LatLng get center => location;
}