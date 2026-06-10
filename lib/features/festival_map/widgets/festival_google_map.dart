import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/stage-area.dart';
import '../providers/participant_location_sender_provider.dart';

class FestivalGoogleMap extends StatefulWidget {
  final LatLng currentLocation;
  final SimulatedParticipantLocation? simulatedLocation;
  final FestivalArea area;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<PointOfInterest>? onPointOfInterestTap;

  const FestivalGoogleMap({
    super.key,
    required this.currentLocation,
    required this.simulatedLocation,
    required this.area,
    required this.onMapCreated,
    required this.onPointOfInterestTap,
  });

  @override
  State<FestivalGoogleMap> createState() => _FestivalGoogleMapState();
}

class _FestivalGoogleMapState extends State<FestivalGoogleMap> {
  final Map<int, BitmapDescriptor> _labelIcons = {};
  final Map<String, BitmapDescriptor> _pointOfInterestIcons = {};
  BitmapDescriptor? _participantIcon;

  @override
  Widget build(BuildContext context) {
    _createMissingLabelIcons(widget.area.stages);
    _createMissingPointOfInterestIcons(widget.area.pointsOfInterest);
    _createParticipantIcon();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.currentLocation,
        zoom: 16,
      ),
      onMapCreated: widget.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      circles: _buildCircles(widget.area),
      markers: _buildMarkers(widget.area),
      polylines: _buildPolylines(),
    );
  }

  Set<Circle> _buildCircles(FestivalArea area) {
    final simulatedLocation = widget.simulatedLocation;

    return {
      Circle(
        circleId: CircleId('${area.id}_festival_circle'),
        center: area.center,
        radius: area.radiusMeters,
        fillColor: area.color.withOpacity(0.12),
        strokeColor: area.color.withOpacity(0.9),
        strokeWidth: 5,
      ),
      ...area.stages.map((stage) {
        final isActive = simulatedLocation?.currentStage?.id == stage.id;
        final isTarget = simulatedLocation?.targetStage?.id == stage.id;

        return Circle(
          circleId: CircleId('${stage.id}_stage_circle'),
          center: stage.center,
          radius: isActive || isTarget ? stage.radiusMeters + 5 : stage.radiusMeters,
          fillColor: stage.color.withOpacity(isActive || isTarget ? 0.46 : 0.28),
          strokeColor: stage.color,
          strokeWidth: isActive || isTarget ? 6 : 4,
        );
      }),
      Circle(
        circleId: const CircleId('participant_glow'),
        center: widget.currentLocation,
        radius: widget.simulatedLocation?.moving == true ? 15 : 9,
        fillColor: Colors.blueAccent.withOpacity(0.22),
        strokeColor: Colors.white.withOpacity(0.9),
        strokeWidth: 2,
      ),
    };
  }

  Set<Polyline> _buildPolylines() {
    final location = widget.simulatedLocation;

    if (location == null ||
        location.previousStage == null ||
        location.targetStage == null) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('participant_route'),
        points: [
          location.previousStage!.center,
          location.position,
          location.targetStage!.center,
        ],
        color: Colors.blueAccent,
        width: 6,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(10),
        ],
      ),
    };
  }

  Set<Marker> _buildMarkers(FestivalArea area) {
    return {
      Marker(
        markerId: MarkerId('${area.id}_festival_label'),
        position: area.center,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: area.name),
      ),
      Marker(
        markerId: const MarkerId('simulated_participant'),
        position: widget.currentLocation,
        icon: _participantIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(title: 'Simulated participant'),
      ),
      ...area.stages.map((stage) {
        return Marker(
          markerId: MarkerId('${stage.id}_stage_label'),
          position: stage.center,
          icon: _labelIcons[stage.id] ??
              BitmapDescriptor.defaultMarkerWithHue(_markerHue(stage.color)),
          anchor: const Offset(0.5, 1),
          infoWindow: InfoWindow(title: stage.name),
        );
      }),
      ...area.pointsOfInterest.map((pointOfInterest) {
        return Marker(
          markerId: MarkerId('${pointOfInterest.id}_point_of_interest'),
          position: pointOfInterest.location,
          icon: _pointOfInterestIcons[pointOfInterest.type] ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          anchor: const Offset(0.5, 0.5),
          onTap: () => widget.onPointOfInterestTap?.call(pointOfInterest),
        );
      }),
    };
  }

  void _createMissingLabelIcons(List<StageArea> stages) {
    for (final stage in stages) {
      if (_labelIcons.containsKey(stage.id)) {
        continue;
      }

      _createLabelIcon(stage.name, stage.color).then((icon) {
        if (!mounted) {
          return;
        }

        setState(() {
          _labelIcons[stage.id] = icon;
        });
      });
    }
  }

  void _createMissingPointOfInterestIcons(List<PointOfInterest> pointsOfInterest) {
    for (final pointOfInterest in pointsOfInterest) {
      if (_pointOfInterestIcons.containsKey(pointOfInterest.type)) {
        continue;
      }

      _createPointOfInterestIcon(
        pointOfInterestIconData(pointOfInterest.type),
        pointOfInterestColor(pointOfInterest.type),
      ).then((icon) {
        if (!mounted) {
          return;
        }

        setState(() {
          _pointOfInterestIcons[pointOfInterest.type] = icon;
        });
      });
    }
  }

  void _createParticipantIcon() {
    if (_participantIcon != null) {
      return;
    }

    _createParticipantBitmap().then((icon) {
      if (!mounted) {
        return;
      }

      setState(() {
        _participantIcon = icon;
      });
    });
  }

  Future<BitmapDescriptor> _createLabelIcon(String text, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const paddingHorizontal = 18.0;
    const paddingVertical = 10.0;
    const pointerHeight = 8.0;
    const borderRadius = 18.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final width = textPainter.width + paddingHorizontal * 2;
    final height = textPainter.height + paddingVertical * 2 + pointerHeight;

    final paint = Paint()..color = color.withOpacity(0.95);

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height - pointerHeight),
      const Radius.circular(borderRadius),
    );

    canvas.drawRRect(bubbleRect, paint);

    final pointerPath = Path()
      ..moveTo(width / 2 - 8, height - pointerHeight)
      ..lineTo(width / 2, height)
      ..lineTo(width / 2 + 8, height - pointerHeight)
      ..close();

    canvas.drawPath(pointerPath, paint);

    textPainter.paint(
      canvas,
      const Offset(
        paddingHorizontal,
        paddingVertical,
      ),
    );

    final image = await recorder.endRecording().toImage(
      width.ceil(),
      height.ceil(),
    );

    final bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
    );
  }

  Future<BitmapDescriptor> _createParticipantBitmap() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const size = 62.0;
    final center = Offset(size / 2, size / 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final outerPaint = Paint()..color = Colors.white;
    final innerPaint = Paint()..color = Colors.blueAccent;

    canvas.drawCircle(center.translate(0, 3), 23, shadowPaint);
    canvas.drawCircle(center, 22, outerPaint);
    canvas.drawCircle(center, 16, innerPaint);

    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '🚶',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      size.ceil(),
      size.ceil(),
    );

    final bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
    );
  }

  Future<BitmapDescriptor> _createPointOfInterestIcon(
      IconData icon,
      Color color,
      ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const size = 46.0;
    const circleSize = 34.0;
    const pointerHeight = 8.0;

    final center = Offset(size / 2, circleSize / 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final paint = Paint()..color = color;

    canvas.drawCircle(
      center.translate(0, 2),
      circleSize / 2,
      shadowPaint,
    );

    canvas.drawCircle(
      center,
      circleSize / 2,
      paint,
    );

    final pointerPath = Path()
      ..moveTo(size / 2 - 6, circleSize - 4)
      ..lineTo(size / 2, circleSize + pointerHeight)
      ..lineTo(size / 2 + 6, circleSize - 4)
      ..close();

    canvas.drawPath(pointerPath, paint);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      size.ceil(),
      (circleSize + pointerHeight + 4).ceil(),
    );

    final bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
    );
  }

  double _markerHue(Color color) {
    return HSVColor.fromColor(color).hue;
  }
}

IconData pointOfInterestIconData(String type) {
  switch (type) {
    case 'BAR':
      return Icons.local_bar_rounded;
    case 'SHOP':
      return Icons.shopping_bag_rounded;
    case 'RESTAURANT':
      return Icons.restaurant_rounded;
    default:
      return Icons.place_rounded;
  }
}

Color pointOfInterestColor(String type) {
  switch (type) {
    case 'BAR':
      return Colors.deepOrangeAccent;
    case 'SHOP':
      return Colors.indigoAccent;
    case 'RESTAURANT':
      return Colors.green;
    default:
      return Colors.teal;
  }
}