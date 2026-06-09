import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../features/festival_map/models/artist-response.dart';
import '../features/festival_map/models/festival-info-response.dart';
import '../features/festival_map/models/lineup-response.dart';
import '../features/festival_map/models/point-of-interest-response.dart';
import '../features/festival_map/models/stage-response.dart';
import '../shared/errors/result.dart';
import 'models/send_participant_location_request.dart';

class CentralServerApiClient {
  final String _baseAddress;
  final http.Client client;

  final headers = {
    'Content-Type': 'application/json',
    'Accept': '*/*',
  };

  CentralServerApiClient(this._baseAddress, this.client);

  Future<Result<bool, Exception>> sendParticipantLocation(
      SendParticipantLocationRequest request,
      ) async {
    try {
      final uri = Uri.parse(_baseAddress).resolve('participant-locations');
      final body = jsonEncode(request.toJson());

      final response = await client
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(true);
      }

      return Failure(
        Exception('Failed: ${response.statusCode} ${response.body}'),
      );
    } on Exception catch (e) {
      log('Error when sending participant location $e');
      return Failure(e);
    }
  }

  Future<Result<FestivalInfoResponse, Exception>> getFestivalInfo() async {
    try {
      final uri = Uri.parse(_baseAddress).resolve('festival/info');

      final response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(
          FestivalInfoResponse.fromJson(
            jsonDecode(response.body),
          ),
        );
      }

      return Failure(
        Exception('Failed: ${response.statusCode} ${response.body}'),
      );
    } on Exception catch (e) {
      log('Error when fetching festival info $e');
      return Failure(e);
    }
  }

  Future<Result<List<StageResponse>, Exception>> getStages() async {
    try {
      final uri = Uri.parse(_baseAddress).resolve('stages');

      final response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as List<dynamic>;

        return Success(
          json
              .map(
                (e) => StageResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
              .toList(),
        );
      }

      return Failure(
        Exception('Failed: ${response.statusCode} ${response.body}'),
      );
    } on Exception catch (e) {
      log('Error when fetching stages $e');
      return Failure(e);
    }
  }

  Future<Result<List<PointOfInterestResponse>, Exception>> getPointsOfInterest() async {
    try {
      final uri = Uri.parse(_baseAddress).resolve('points-of-interest');

      final response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as List<dynamic>;

        return Success(
          json
              .map(
                (e) => PointOfInterestResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
              .toList(),
        );
      }

      return Failure(
        Exception('Failed: ${response.statusCode} ${response.body}'),
      );
    } on Exception catch (e) {
      log('Error when fetching points of interest $e');
      return Failure(e);
    }
  }

  Future<Result<List<ArtistResponse>, Exception>> getArtists() async {
    try {
      final uri = Uri.parse(_baseAddress).resolve('artists');

      final response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as List<dynamic>;

        return Success(
          json
              .map(
                (e) => ArtistResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
              .toList(),
        );
      }

      return Failure(
        Exception('Failed: ${response.statusCode} ${response.body}'),
      );
    } on Exception catch (e) {
      log('Error when fetching artists $e');
      return Failure(e);
    }
  }

  Future<Result<List<LineupResponse>, Exception>> getLineup() async {
    try {
      final uri = Uri.parse(_baseAddress).resolve('lineup');

      final response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as List<dynamic>;

        return Success(
          json
              .map(
                (e) => LineupResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
              .toList(),
        );
      }

      return Failure(
        Exception('Failed: ${response.statusCode} ${response.body}'),
      );
    } on Exception catch (e) {
      log('Error when fetching lineup $e');
      return Failure(e);
    }
  }
}