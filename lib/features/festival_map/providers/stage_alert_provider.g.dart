// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_alert_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stageAlert)
final stageAlertProvider = StageAlertProvider._();

final class StageAlertProvider extends $FunctionalProvider<
        AsyncValue<FestivalAlert>, FestivalAlert, Stream<FestivalAlert>>
    with $FutureModifier<FestivalAlert>, $StreamProvider<FestivalAlert> {
  StageAlertProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'stageAlertProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$stageAlertHash();

  @$internal
  @override
  $StreamProviderElement<FestivalAlert> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<FestivalAlert> create(Ref ref) {
    return stageAlert(ref);
  }
}

String _$stageAlertHash() => r'58bbebf6c6e5578cbb26cc51960704facca213bc';
