import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/stage-area.dart';

class FestivalGoogleMap extends StatefulWidget {
  final LatLng currentLocation;
  final FestivalArea? area;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<PointOfInterest>? onPointOfInterestTap;

  const FestivalGoogleMap({
    super.key,
    required this.currentLocation,
    required this.area,
    required this.onMapCreated,
    required this.onPointOfInterestTap,
  });

  const FestivalGoogleMap.loading({
    super.key,
    required this.currentLocation,
    required this.onMapCreated,
  })  : area = null,
        onPointOfInterestTap = null;

  @override
  State<FestivalGoogleMap> createState() => _FestivalGoogleMapState();
}

class _FestivalGoogleMapState extends State<FestivalGoogleMap> {
  final Map<int, BitmapDescriptor> _labelIcons = {};
  final Map<String, BitmapDescriptor> _pointOfInterestIcons = {};

  @override
  Widget build(BuildContext context) {
    final area = widget.area;

    if (area == null) {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.currentLocation,
          zoom: 16,
        ),
        onMapCreated: widget.onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      );
    }

    _createMissingLabelIcons(area.stages);
    _createMissingPointOfInterestIcons(area.pointsOfInterest);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.currentLocation,
        zoom: 16,
      ),
      onMapCreated: widget.onMapCreated,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      polygons: _buildPolygons(area),
      markers: _buildMarkers(area),
    );
  }

  Set<Polygon> _buildPolygons(FestivalArea area) {
    return {
      Polygon(
        polygonId: PolygonId(area.id.toString()),
        points: area.points,
        fillColor: area.color.withOpacity(0.12),
        strokeColor: area.color.withOpacity(0.9),
        strokeWidth: 5,
      ),
      ...area.stages.map((stage) {
        return Polygon(
          polygonId: PolygonId(stage.id.toString()),
          points: stage.points,
          fillColor: stage.color.withOpacity(0.38),
          strokeColor: stage.color,
          strokeWidth: 4,
        );
      }),
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
      ...area.stages.map((stage) {
        return Marker(
          markerId: MarkerId('${stage.id}_stage_label'),
          position: stage.center,
          icon: _labelIcons[stage.id] ??
              BitmapDescriptor.defaultMarkerWithHue(_markerHue(stage.color)),
          anchor: const Offset(0.5, 0.5),
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