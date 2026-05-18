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
    r'dd376578d542b9be0cc8a08623f3f4910a87eb96';

@ProviderFor(FestivalAreaData)
final festivalAreaDataProvider = FestivalAreaDataFamily._();

final class FestivalAreaDataProvider
    extends $AsyncNotifierProvider<FestivalAreaData, FestivalArea> {
  FestivalAreaDataProvider._(
      {required FestivalAreaDataFamily super.from,
      required LatLng super.argument})
      : super(
          retry: null,
          name: r'festivalAreaDataProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$festivalAreaDataHash();

  @override
  String toString() {
    return r'festivalAreaDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FestivalAreaData create() => FestivalAreaData();

  @override
  bool operator ==(Object other) {
    return other is FestivalAreaDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$festivalAreaDataHash() => r'7e566722e44def2083f95b6022b0a7ceb6c4000c';

final class FestivalAreaDataFamily extends $Family
    with
        $ClassFamilyOverride<FestivalAreaData, AsyncValue<FestivalArea>,
            FestivalArea, FutureOr<FestivalArea>, LatLng> {
  FestivalAreaDataFamily._()
      : super(
          retry: null,
          name: r'festivalAreaDataProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FestivalAreaDataProvider call(
    LatLng center,
  ) =>
      FestivalAreaDataProvider._(argument: center, from: this);

  @override
  String toString() => r'festivalAreaDataProvider';
}

abstract class _$FestivalAreaData extends $AsyncNotifier<FestivalArea> {
  late final _$args = ref.$arg as LatLng;
  LatLng get center => _$args;

  FutureOr<FestivalArea> build(
    LatLng center,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FestivalArea>, FestivalArea>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<FestivalArea>, FestivalArea>,
        AsyncValue<FestivalArea>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
