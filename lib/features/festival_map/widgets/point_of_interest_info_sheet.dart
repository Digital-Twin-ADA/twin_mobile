import 'package:flutter/material.dart';

import '../models/stage-area.dart';
import 'festival_google_map.dart';
import 'festival_metric_card.dart';
import 'info_row.dart';

class PointOfInterestInfoSheet extends StatelessWidget {
  final PointOfInterest pointOfInterest;

  const PointOfInterestInfoSheet({
    super.key,
    required this.pointOfInterest,
  });

  @override
  Widget build(BuildContext context) {
    final icon = pointOfInterestIconData(pointOfInterest.type);
    final color = pointOfInterestColor(pointOfInterest.type);

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
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    pointOfInterest.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              pointOfInterest.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FestivalMetricCard(
                    label: 'Type',
                    value: pointOfInterest.type,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FestivalMetricCard(
                    label: 'Zone',
                    value: pointOfInterest.zoneCode ?? '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.schedule_rounded,
              label: pointOfInterest.openingHours,
            ),
          ],
        ),
      ),
    );
  }
}