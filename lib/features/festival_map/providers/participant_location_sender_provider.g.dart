// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_location_sender_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SimulatedParticipantLocationState)
final simulatedParticipantLocationStateProvider =
    SimulatedParticipantLocationStateProvider._();

final class SimulatedParticipantLocationStateProvider extends $NotifierProvider<
    SimulatedParticipantLocationState, SimulatedParticipantLocation?> {
  SimulatedParticipantLocationStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'simulatedParticipantLocationStateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() =>
      _$simulatedParticipantLocationStateHash();

  @$internal
  @override
  SimulatedParticipantLocationState create() =>
      SimulatedParticipantLocationState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SimulatedParticipantLocation? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<SimulatedParticipantLocation?>(value),
    );
  }
}

String _$simulatedParticipantLocationStateHash() =>
    r'065f2362b7533dcb79df6d41086dc32a4c1ba146';

abstract class _$SimulatedParticipantLocationState
    extends $Notifier<SimulatedParticipantLocation?> {
  SimulatedParticipantLocation? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<SimulatedParticipantLocation?, SimulatedParticipantLocation?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SimulatedParticipantLocation?,
            SimulatedParticipantLocation?>,
        SimulatedParticipantLocation?,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(participantLocationSender)
final participantLocationSenderProvider = ParticipantLocationSenderProvider._();

final class ParticipantLocationSenderProvider extends $FunctionalProvider<
    ParticipantLocationSender,
    ParticipantLocationSender,
    ParticipantLocationSender> with $Provider<ParticipantLocationSender> {
  ParticipantLocationSenderProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'participantLocationSenderProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$participantLocationSenderHash();

  @$internal
  @override
  $ProviderElement<ParticipantLocationSender> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ParticipantLocationSender create(Ref ref) {
    return participantLocationSender(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParticipantLocationSender value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParticipantLocationSender>(value),
    );
  }
}

String _$participantLocationSenderHash() =>
    r'80e276000a3c2d695ff3bc637638f4365d1b47eb';
