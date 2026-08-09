import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/leave.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/remote_leave_repository.dart';
import '../../domain/repositories/leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>(
  (ref) => RemoteLeaveRepository(
    ref.read(apiClientProvider),
    ref.read(tokenStorageProvider),
  ),
  name: 'leaveRepository',
);

final leaveRequestsProvider = StateNotifierProvider<LeaveRequestsController, AsyncValue<List<LeaveRequest>>>(
      (ref) => LeaveRequestsController(ref.read(leaveRepositoryProvider), ref),
  name: 'leaveRequests',
);

class LeaveRequestsController extends StateNotifier<AsyncValue<List<LeaveRequest>>> {
  LeaveRequestsController(this._repository, this._ref) : super(const AsyncLoading()) {
    refresh();
  }

  final LeaveRepository _repository;
  final Ref _ref;

  Future<void> refresh() async {
    final prev = state;
    if (prev is! AsyncData) {
      state = const AsyncLoading();
    }

    try {
      final requests = await _repository.getRequests()
          .timeout(const Duration(seconds: 12));
      log('✅ Leave requests loaded: ${requests.length}');
      state = AsyncData(requests);
    } catch (e, st) {
      log('⚠️ Leave requests refresh failed: $e');
      if (prev is AsyncData<List<LeaveRequest>>) {
        state = prev;
      } else {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> submit(NewLeaveRequest request) async {
    final prev = state;
    state = const AsyncLoading<List<LeaveRequest>>().copyWithPrevious(prev);
    try {
      final created = await _repository.submitRequest(request)
          .timeout(const Duration(seconds: 15));
      final current = prev.valueOrNull ?? const <LeaveRequest>[];
      state = AsyncData([created, ...current]);
      _ref.invalidate(recentActivitiesProvider);
      _ref.invalidate(attendanceMonthProvider);
      _ref.invalidate(leaveBalanceProvider);
    } catch (e) {
      state = prev;
      rethrow;
    }
  }
}

final leaveBalanceProvider = FutureProvider.autoDispose<List<LeaveBalance>>((ref) {
  final repo = ref.watch(leaveRepositoryProvider);
  return repo.getBalances();
}, name: 'leaveBalances');

final leaveDetailProvider = FutureProvider.family.autoDispose<LeaveRequest, String>((ref, id) {
  final repo = ref.watch(leaveRepositoryProvider);
  return repo.getRequestById(id).then((request) {
    if (request == null) throw const NotFoundFailure('Leave request not found.');
    return request;
  });
}, name: 'leaveDetail');
