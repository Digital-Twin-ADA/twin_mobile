import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StageArea {
  final String id;
  final String name;
  final List<LatLng> points;
  final Color color;

  const StageArea({
    required this.id,
    required this.name,
    required this.points,
    required this.color,
  });

  LatLng get center {
    final latitude = points.map((point) => point.latitude).reduce((a, b) => a + b) / points.length;
    final longitude = points.map((point) => point.longitude).reduce((a, b) => a + b) / points.length;

    return LatLng(latitude, longitude);
  }
}

class FestivalArea {
  final String id;
  final String name;
  final List<LatLng> points;
  final Color color;
  final List<StageArea> stages;

  const FestivalArea({
    required this.id,
    required this.name,
    required this.points,
    required this.color,
    required this.stages,
  });

  LatLng get center {
    final latitude = points.map((point) => point.latitude).reduce((a, b) => a + b) / points.length;
    final longitude = points.map((point) => point.longitude).reduce((a, b) => a + b) / points.length;

    return LatLng(latitude, longitude);
  }
}