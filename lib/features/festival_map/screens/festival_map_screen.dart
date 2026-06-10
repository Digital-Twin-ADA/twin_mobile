import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/stage-area.dart';
import '../providers/participant_location_sender_provider.dart';
import '../providers/stage_area_provider.dart';
import '../widgets/festival_google_map.dart';
import '../widgets/festival_header_card.dart';
import '../widgets/festival_info_sheet.dart';
import '../widgets/map_error_views.dart';
import '../widgets/point_of_interest_info_sheet.dart';

import '../providers/stage_alert_provider.dart';
import '../widgets/festival_alert_banner.dart';

class FestivalMapScreen extends ConsumerStatefulWidget {
  const FestivalMapScreen({super.key});

  @override
  ConsumerState<FestivalMapScreen> createState() => _FestivalMapScreenState();
}

class _FestivalMapScreenState extends ConsumerState<FestivalMapScreen> {
  GoogleMapController? _controller;
  LatLng? _lastCameraPosition;

  @override
  Widget build(BuildContext context) {
    return _FestivalMapBody(
      controller: _controller,
      onControllerCreated: (controller) {
        _controller = controller;
      },
      onFocusFestival: _focusFestival,
      onFocusPointOfInterest: _focusPointOfInterest,
      onShowFestivalInfo: _showFestivalInfo,
      onShowPointOfInterestInfo: _showPointOfInterestInfo,
      onFollowParticipant: _followParticipant,
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
      CameraUpdate.newLatLngZoom(
        area.center,
        16,
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

  Future<void> _followParticipant(LatLng position, bool moving) async {
    final controller = _controller;

    if (controller == null) {
      return;
    }

    final previous = _lastCameraPosition;
    _lastCameraPosition = position;

    if (!moving && previous != null) {
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        position,
        moving ? 17.3 : 16.8,
      ),
    );
  }
}

class _FestivalMapBody extends ConsumerWidget {
  final GoogleMapController? controller;
  final ValueChanged<GoogleMapController> onControllerCreated;
  final ValueChanged<FestivalArea> onFocusFestival;
  final ValueChanged<PointOfInterest> onFocusPointOfInterest;
  final ValueChanged<FestivalArea> onShowFestivalInfo;
  final ValueChanged<PointOfInterest> onShowPointOfInterestInfo;
  final Future<void> Function(LatLng position, bool moving) onFollowParticipant;

  const _FestivalMapBody({
    required this.controller,
    required this.onControllerCreated,
    required this.onFocusFestival,
    required this.onFocusPointOfInterest,
    required this.onShowFestivalInfo,
    required this.onShowPointOfInterestInfo,
    required this.onFollowParticipant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalArea = ref.watch(festivalAreaDataProvider);
    final simulatedLocation = ref.watch(simulatedParticipantLocationStateProvider);
    final stageAlert = ref.watch(stageAlertProvider);

    return Stack(
      children: [
        festivalArea.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => FestivalErrorView(error: error),
          data: (area) {
            final participantLocation = simulatedLocation?.position ?? area.center;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              onFollowParticipant(
                participantLocation,
                simulatedLocation?.moving ?? false,
              );
            });

            return FestivalGoogleMap(
              currentLocation: participantLocation,
              simulatedLocation: simulatedLocation,
              area: area,
              onMapCreated: onControllerCreated,
              onPointOfInterestTap: (pointOfInterest) {
                onFocusPointOfInterest(pointOfInterest);
                onShowPointOfInterestInfo(pointOfInterest);
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
        stageAlert.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (alert) {
            return Positioned(
              top: 92,
              left: 16,
              right: 16,
              child: FestivalAlertBanner(
                alert: alert,
              ),
            );
          },
        ),
        if (simulatedLocation?.moving == true)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _MovementCard(location: simulatedLocation!),
          ),
      ],
    );
  }
}

class _MovementCard extends StatelessWidget {
  final SimulatedParticipantLocation location;

  const _MovementCard({
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final from = location.previousStage?.name ?? 'Festival';
    final to = location.targetStage?.name ?? 'Next stage';

    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(24),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.directions_walk_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moving to $to',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$from → $to',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: location.progress,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}