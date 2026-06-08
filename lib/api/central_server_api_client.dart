import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

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
}