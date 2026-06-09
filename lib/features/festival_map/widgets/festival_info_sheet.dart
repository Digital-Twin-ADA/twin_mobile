import 'package:flutter/material.dart';

import '../models/stage-area.dart';
import 'artist_preview_tile.dart';
import 'festival_lineup_sheet.dart';
import 'festival_metric_card.dart';

class FestivalInfoSheet extends StatelessWidget {
  final FestivalArea area;
  final VoidCallback onGoToFestival;

  const FestivalInfoSheet({
    super.key,
    required this.area,
    required this.onGoToFestival,
  });

  @override
  Widget build(BuildContext context) {
    final totalCapacity = area.stages.fold<int>(
      0,
          (sum, stage) => sum + stage.capacity,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.festival_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        area.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  area.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FestivalMetricCard(
                        label: 'Stages',
                        value: area.stages.length.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FestivalMetricCard(
                        label: 'Capacity',
                        value: totalCapacity.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FestivalMetricCard(
                        label: 'Artists',
                        value: area.artists.length.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onGoToFestival,
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text('Go to festival'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return FestivalLineupSheet(
                          lineup: area.lineup,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.event_note_rounded),
                  label: const Text('See lineup'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Artists',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ...area.artists.map((artist) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ArtistPreviewTile(artist: artist),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}