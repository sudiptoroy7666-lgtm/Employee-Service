import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../network/location_service.dart';
import '../network/token_storage.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());
final tokenStorageProvider = Provider((ref) => TokenStorage(ref.read(secureStorageProvider)));
final apiClientProvider = Provider((ref) => ApiClient(tokenStorage: ref.read(tokenStorageProvider)));
final locationServiceProvider = Provider((ref) => LocationService());

/// Emits the current time every 60 seconds so live clock widgets stay fresh.
final clockProvider = StreamProvider<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  controller.add(DateTime.now());
  final timer = Timer.periodic(const Duration(seconds: 60), (_) => controller.add(DateTime.now()));
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});
