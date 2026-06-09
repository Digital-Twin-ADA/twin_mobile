import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/stage-area.dart';
import '../providers/location_provider.dart';
import '../providers/stage_area_provider.dart';
import '../widgets/festival_google_map.dart';
import '../widgets/festival_header_card.dart';
import '../widgets/festival_info_sheet.dart';
import '../widgets/location_permission_view.dart';
import '../widgets/map_error_views.dart';
import '../widgets/point_of_interest_info_sheet.dart';

class FestivalMapScreen extends ConsumerStatefulWidget {
  const FestivalMapScreen({super.key});

  @override
  ConsumerState<FestivalMapScreen> createState() => _FestivalMapScreenState();
}

class _FestivalMapScreenState extends ConsumerState<FestivalMapScreen> {
  GoogleMapController? _controller;
  bool _cameraMovedToUser = false;

  @override
  Widget build(BuildContext context) {
    final permission = ref.watch(locationPermissionProvider);

    return permission.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const LocationErrorView(),
      data: (permission) {
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return const LocationPermissionView();
        }

        return _FestivalMapBody(
          controller: _controller,
          cameraMovedToUser: _cameraMovedToUser,
          onControllerCreated: (controller) {
            _controller = controller;
          },
          onCameraMovedToUser: () {
            _cameraMovedToUser = true;
          },
          onFocusFestival: _focusFestival,
          onFocusPointOfInterest: _focusPointOfInterest,
          onShowFestivalInfo: _showFestivalInfo,
          onShowPointOfInterestInfo: _showPointOfInterestInfo,
        );
      },
    );
  }

  void _showFestivalInfo(FestivalArea area) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FestivalInfoSheet(
          area: area,
          onGoToFestival: () {
            Navigator.of(context).pop();
            _focusFestival(area);
          },
        );
      },
    );
  }

  void _showPointOfInterestInfo(PointOfInterest pointOfInterest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PointOfInterestInfoSheet(pointOfInterest: pointOfInterest);
      },
    );
  }

  Future<void> _focusFestival(FestivalArea area) async {
    final controller = _controller;

    if (controller == null) {
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        _boundsFromPoints(area.points),
        80,
      ),
    );
  }

  Future<void> _focusPointOfInterest(PointOfInterest pointOfInterest) async {
    final controller = _controller;

    if (controller == null) {
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        pointOfInterest.location,
        18,
      ),
    );
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    var south = points.first.latitude;
    var north = points.first.latitude;
    var west = points.first.longitude;
    var east = points.first.longitude;

    for (final point in points) {
      south = point.latitude < south ? point.latitude : south;
      north = point.latitude > north ? point.latitude : north;
      west = point.longitude < west ? point.longitude : west;
      east = point.longitude > east ? point.longitude : east;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }
}

class _FestivalMapBody extends ConsumerWidget {
  final GoogleMapController? controller;
  final bool cameraMovedToUser;
  final ValueChanged<GoogleMapController> onControllerCreated;
  final VoidCallback onCameraMovedToUser;
  final ValueChanged<FestivalArea> onFocusFestival;
  final ValueChanged<PointOfInterest> onFocusPointOfInterest;
  final ValueChanged<FestivalArea> onShowFestivalInfo;
  final ValueChanged<PointOfInterest> onShowPointOfInterestInfo;

  const _FestivalMapBody({
    required this.controller,
    required this.cameraMovedToUser,
    required this.onControllerCreated,
    required this.onCameraMovedToUser,
    required this.onFocusFestival,
    required this.onFocusPointOfInterest,
    required this.onShowFestivalInfo,
    required this.onShowPointOfInterestInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(userLocationStreamProvider);
    final festivalArea = ref.watch(festivalAreaDataProvider);

    return Stack(
      children: [
        location.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const LocationErrorView(),
          data: (position) {
            final currentLocation = LatLng(
              position.latitude,
              position.longitude,
            );

            if (!cameraMovedToUser) {
              onCameraMovedToUser();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller?.animateCamera(
                  CameraUpdate.newLatLngZoom(currentLocation, 16),
                );
              });
            }

            return festivalArea.when(
              loading: () => FestivalGoogleMap.loading(
                currentLocation: currentLocation,
                onMapCreated: onControllerCreated,
              ),
              error: (error, _) => FestivalErrorView(error: error),
              data: (area) {
                return FestivalGoogleMap(
                  currentLocation: currentLocation,
                  area: area,
                  onMapCreated: onControllerCreated,
                  onPointOfInterestTap: (pointOfInterest) {
                    onFocusPointOfInterest(pointOfInterest);
                    onShowPointOfInterestInfo(pointOfInterest);
                  },
                );
              },
            );
          },
        ),
        festivalArea.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (area) {
            return Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: FestivalHeaderCard(
                area: area,
                onTap: () => onShowFestivalInfo(area),
              ),
            );
          },
        ),
      ],
    );
  }
}