import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_provider.g.dart';

@riverpod
Future<LocationPermission> locationPermission(Ref ref) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return LocationPermission.denied;
  }

  var permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return permission;
}

@riverpod
Stream<Position> userLocationStream(Ref ref) {
  const settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  return Geolocator.getPositionStream(locationSettings: settings);
}