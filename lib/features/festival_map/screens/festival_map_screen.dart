import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/location_provider.dart';

class FestivalMapScreen extends ConsumerStatefulWidget {
  const FestivalMapScreen({super.key});

  @override
  ConsumerState<FestivalMapScreen> createState() => _FestivalMapScreenState();
}

class _FestivalMapScreenState extends ConsumerState<FestivalMapScreen> {
  GoogleMapController? _mapController;

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

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(userLocationStreamProvider);

    return location.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _LocationErrorView(),
      data: (position) {
        final currentLocation = LatLng(position.latitude, position.longitude);

        _controller?.animateCamera(
          CameraUpdate.newLatLng(currentLocation),
        );

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentLocation,
            zoom: 17,
          ),
          onMapCreated: (controller) {
            _controller = controller;
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        );
      },
    );
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