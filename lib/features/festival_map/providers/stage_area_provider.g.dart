// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_area_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stageAreaRepository)
final stageAreaRepositoryProvider = StageAreaRepositoryProvider._();

final class StageAreaRepositoryProvider extends $FunctionalProvider<
    StageAreaRepository,
    StageAreaRepository,
    StageAreaRepository> with $Provider<StageAreaRepository> {
  StageAreaRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'stageAreaRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$stageAreaRepositoryHash();

  @$internal
  @override
  $ProviderElement<StageAreaRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StageAreaRepository create(Ref ref) {
    return stageAreaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StageAreaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StageAreaRepository>(value),
    );
  }
}

String _$stageAreaRepositoryHash() =>
    r'cfae3713e34302141126f1f18317ef31d2f32f8c';

@ProviderFor(festivalAreaData)
final festivalAreaDataProvider = FestivalAreaDataProvider._();

final class FestivalAreaDataProvider extends $FunctionalProvider<
        AsyncValue<FestivalArea>, FestivalArea, FutureOr<FestivalArea>>
    with $FutureModifier<FestivalArea>, $FutureProvider<FestivalArea> {
  FestivalAreaDataProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'festivalAreaDataProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$festivalAreaDataHash();

  @$internal
  @override
  $FutureProviderElement<FestivalArea> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<FestivalArea> create(Ref ref) {
    return festivalAreaData(ref);
  }
}

String _$festivalAreaDataHash() => r'a80889fe3281c16dea74813db01bc2185b59bf2a';
