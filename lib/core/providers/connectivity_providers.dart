import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = FutureProvider<ConnectivityResult>((ref) async {
  final result = await Connectivity().checkConnectivity();
  return result.first;
}, name: 'connectivity');

final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.valueOrNull != ConnectivityResult.none;
}, name: 'isOnline');
