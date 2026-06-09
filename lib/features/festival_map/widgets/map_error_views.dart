import 'package:flutter/material.dart';

class FestivalErrorView extends StatelessWidget {
  final Object error;

  const FestivalErrorView({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Festival could not be loaded: $error'),
    );
  }
}

class LocationErrorView extends StatelessWidget {
  const LocationErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Location could not be loaded'),
    );
  }
}