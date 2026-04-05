import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/result.dart';

class SecureStorage {
  final FlutterSecureStorage _flutterSecureStorage;

  SecureStorage({required FlutterSecureStorage flutterSecureStorage}) : _flutterSecureStorage = flutterSecureStorage;

  Future<Result<void, Exception>> clearStorage() async {
    try {
      await _flutterSecureStorage.deleteAll();
      return const Success(null);
    } on Exception catch (e) {
      log("Error clearing storage: $e");
      return Failure(Exception("Unable to clear storage"));
    }
  }
}