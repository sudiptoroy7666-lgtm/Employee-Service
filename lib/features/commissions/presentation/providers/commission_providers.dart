import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_commission_repository.dart';
import '../../domain/models/commission.dart';
import '../../domain/repositories/commission_repository.dart';

final commissionRepositoryProvider = Provider<CommissionRepository>((ref) {
  return RemoteCommissionRepository(ref.read(apiClientProvider));
}, name: 'commissionRepository');

final commissionsProvider = FutureProvider.autoDispose<List<Commission>>((ref) {
  final repo = ref.watch(commissionRepositoryProvider);
  return repo.getCommissions();
}, name: 'commissions');
