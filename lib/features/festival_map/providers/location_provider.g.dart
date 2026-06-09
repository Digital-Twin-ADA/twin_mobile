// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(locationPermission)
final locationPermissionProvider = LocationPermissionProvider._();

final class LocationPermissionProvider extends $FunctionalProvider<
        AsyncValue<LocationPermission>,
        LocationPermission,
        FutureOr<LocationPermission>>
    with
        $FutureModifier<LocationPermission>,
        $FutureProvider<LocationPermission> {
  LocationPermissionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationPermissionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationPermissionHash();

  @$internal
  @override
  $FutureProviderElement<LocationPermission> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LocationPermission> create(Ref ref) {
    return locationPermission(ref);
  }
}

String _$locationPermissionHash() =>
    r'90f980da8171e096b7a47c93ccc47f5a69931104';

@ProviderFor(userLocationStream)
final userLocationStreamProvider = UserLocationStreamProvider._();

final class UserLocationStreamProvider extends $FunctionalProvider<
        AsyncValue<Position>, Position, Stream<Position>>
    with $FutureModifier<Position>, $StreamProvider<Position> {
  UserLocationStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userLocationStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userLocationStreamHash();

  @$internal
  @override
  $StreamProviderElement<Position> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Position> create(Ref ref) {
    return userLocationStream(ref);
  }
}

String _$userLocationStreamHash() =>
    r'49b3970f33c0ba8d15350da37fe94cf8ce5cf70b';
