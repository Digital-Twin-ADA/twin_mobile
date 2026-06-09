import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/location_provider.dart';

class LocationPermissionView extends ConsumerWidget {
  const LocationPermissionView({super.key});

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