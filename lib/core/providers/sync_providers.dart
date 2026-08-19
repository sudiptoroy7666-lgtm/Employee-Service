import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sync/offline_sync_service.dart';
import 'connectivity_providers.dart';
import '../../features/visits/presentation/providers/visit_providers.dart';
import '../../features/promotions/presentation/providers/promotion_providers.dart';

final pendingSyncCountProvider = FutureProvider.autoDispose<int>((ref) {
  return OfflineSyncService.getPendingCount();
}, name: 'pendingSyncCount');

final autoSyncProvider = Provider<void>((ref) {
  final isOnline = ref.watch(isOnlineProvider);

  if (isOnline) {
    Future.microtask(() async {
      final result = await OfflineSyncService.processPending();
      if (result.success > 0) {
        log('Auto-sync completed: ${result.message}');
        ref.invalidate(visitsProvider);
        ref.invalidate(promotionsProvider);
        ref.invalidate(pendingSyncCountProvider);
      }
    });
  }
}, name: 'autoSync');
