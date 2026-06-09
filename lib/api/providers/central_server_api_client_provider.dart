import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/config.dart';
import '../central_server_api_client.dart';

part 'central_server_api_client_provider.g.dart';

@Riverpod(keepAlive: true)
http.Client httpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
CentralServerApiClient centralServerApiClient(Ref ref) {
  return CentralServerApiClient(
    AppConfig.centralServerApiBaseAddress,
    ref.watch(httpClientProvider),
  );
}