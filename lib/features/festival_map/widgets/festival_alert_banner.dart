import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/festival-alert.dart';

class FestivalAlertBanner extends StatefulWidget {
  final FestivalAlert alert;

  const FestivalAlertBanner({
    super.key,
    required this.alert,
  });

  @override
  State<FestivalAlertBanner> createState() => _FestivalAlertBannerState();
}

class _FestivalAlertBannerState extends State<FestivalAlertBanner> {
  final Set<int> _dismissedAlertIds = {};

  @override
  Widget build(BuildContext context) {
    if (_dismissedAlertIds.contains(widget.alert.id)) {
      return const SizedBox.shrink();
    }

    final color = _severityColor(widget.alert.severity);
    final icon = _severityIcon(widget.alert.severity);
    final time = DateFormat('HH:mm').format(widget.alert.createdAt.toLocal());

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: Material(
        elevation: 14,
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withOpacity(0.55),
              width: 1.4,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.22),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.42),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.alert.type.toUpperCase(),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: color,
                              letterSpacing: 0.7,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.alert.message,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Stage ${widget.alert.stageId} • ${widget.alert.severity.toUpperCase()}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _dismissedAlertIds.add(widget.alert.id);
                  });
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'danger':
      case 'high':
        return Colors.redAccent;
      case 'warning':
      case 'medium':
        return Colors.orangeAccent;
      case 'info':
      case 'low':
        return Colors.blueAccent;
      default:
        return Colors.deepPurpleAccent;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'danger':
      case 'high':
        return Icons.priority_high_rounded;
      case 'warning':
      case 'medium':
        return Icons.warning_amber_rounded;
      case 'info':
      case 'low':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
}