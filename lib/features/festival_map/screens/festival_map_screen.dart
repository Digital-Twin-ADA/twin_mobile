import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/stage-area.dart';
import '../providers/location_provider.dart';
import '../providers/stage_area_provider.dart';

class FestivalMapScreen extends ConsumerStatefulWidget {
  const FestivalMapScreen({super.key});

  @override
  ConsumerState<FestivalMapScreen> createState() => _FestivalMapScreenState();
}

class _FestivalMapScreenState extends ConsumerState<FestivalMapScreen> {
  @override
  Widget build(BuildContext context) {
    final permission = ref.watch(locationPermissionProvider);

    return permission.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _LocationErrorView(),
      data: (permission) {
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return const _LocationPermissionView();
        }

        return const _FestivalMapBody();
      },
    );
  }
}

class _FestivalMapBody extends ConsumerStatefulWidget {
  const _FestivalMapBody();

  @override
  ConsumerState<_FestivalMapBody> createState() => _FestivalMapBodyState();
}

class _FestivalMapBodyState extends ConsumerState<_FestivalMapBody> {
  GoogleMapController? _controller;
  bool _cameraMovedToUser = false;
  LatLng? _festivalCenter;
  final Map<String, BitmapDescriptor> _labelIcons = {};

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(userLocationStreamProvider);

    return location.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _LocationErrorView(),
      data: (position) {
        final currentLocation = LatLng(position.latitude, position.longitude);
        _festivalCenter ??= currentLocation;

        final festivalArea = ref.watch(festivalAreaDataProvider(_festivalCenter!));

        if (!_cameraMovedToUser) {
          _cameraMovedToUser = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _controller?.animateCamera(
              CameraUpdate.newLatLngZoom(currentLocation, 16),
            );
          });
        }

        return festivalArea.when(
          loading: () => GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _controller = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          error: (_, __) => const _LocationErrorView(),
          data: (area) {
            _createMissingLabelIcons(area.stages);

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation,
                zoom: 16,
              ),
              onMapCreated: (controller) {
                _controller = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              polygons: {
                Polygon(
                  polygonId: PolygonId(area.id),
                  points: area.points,
                  fillColor: area.color.withOpacity(0.12),
                  strokeColor: area.color.withOpacity(0.9),
                  strokeWidth: 5,
                ),
                ...area.stages.map((stage) {
                  return Polygon(
                    polygonId: PolygonId(stage.id),
                    points: stage.points,
                    fillColor: stage.color.withOpacity(0.38),
                    strokeColor: stage.color,
                    strokeWidth: 4,
                  );
                }),
              },
              markers: {
                Marker(
                  markerId: MarkerId('${area.id}_label'),
                  position: area.center,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  infoWindow: InfoWindow(
                    title: area.name,
                  ),
                ),
                ...area.stages.map((stage) {
                  return Marker(
                    markerId: MarkerId('${stage.id}_label'),
                    position: stage.center,
                    icon: _labelIcons[stage.id] ?? BitmapDescriptor.defaultMarkerWithHue(_markerHue(stage.color)),
                    anchor: const Offset(0.5, 0.5),
                    infoWindow: InfoWindow(
                      title: stage.name,
                    ),
                  );
                }),
              },
            );
          },
        );
      },
    );
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
      Offset(
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

  double _markerHue(Color color) {
    return HSVColor.fromColor(color).hue;
  }
}

class _LocationPermissionView extends ConsumerWidget {
  const _LocationPermissionView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FilledButton.icon(
          onPressed: () {
            ref.invalidate(locationPermissionProvider);
          },
          icon: const Icon(Icons.location_on_outlined),
          label: const Text('Allow location access'),
        ),
      ),
    );
  }
}

class _LocationErrorView extends StatelessWidget {
  const _LocationErrorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Location could not be loaded'),
    );
  }
}