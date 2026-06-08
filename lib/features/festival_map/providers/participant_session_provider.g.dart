// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(participantId)
final participantIdProvider = ParticipantIdProvider._();

final class ParticipantIdProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  ParticipantIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'participantIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$participantIdHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return participantId(ref);
  }
}

String _$participantIdHash() => r'41c4479e370c28226acf0fb9e5ada0878f1e60a4';
