import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/attendance.dart';
import '../../../../core/models/check_in_out.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_attendance_repository.dart';
import '../../domain/repositories/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => RemoteAttendanceRepository(
    ref.read(apiClientProvider),
    ref.read(tokenStorageProvider),
    ref.read(locationServiceProvider),
  ),
  name: 'attendanceRepository',
);

/// Month attendance for the calendar + summary (family by month).
final attendanceMonthProvider = FutureProvider.family.autoDispose<MonthAttendance, DateTime>((ref, month) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getMonthAttendance(month);
});

/// Single attendance record (family by record id).
final attendanceRecordProvider = FutureProvider.family.autoDispose<AttendanceRecord, String>((ref, id) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  final record = await repo.getRecordById(id);
  if (record == null) throw const NotFoundFailure('This attendance record is not available.');
  return record;
});

/// Today's check-in / check-out state, with actions to check in / out.
final todayAttendanceProvider =
    StateNotifierProvider<TodayAttendanceController, AsyncValue<CheckInOutRecord>>(
      (ref) => TodayAttendanceController(ref.watch(attendanceRepositoryProvider), ref),
    );

class TodayAttendanceController extends StateNotifier<AsyncValue<CheckInOutRecord>> {
  TodayAttendanceController(this._repository, this._ref) : super(const AsyncLoading()) {
    refresh();
  }

  final AttendanceRepository _repository;
  final Ref _ref;

  Future<void> refresh() async {
    final prev = state;

    if (prev is! AsyncData) {
      state = const AsyncLoading();
    }

    try {
      final record = await _repository.getToday()
          .timeout(const Duration(seconds: 12));
      
      debugPrint('✅ TodayAttendance loaded: checkIn=${record.checkInTime}, checkOut=${record.checkOutTime}');
      state = AsyncData(record);
    } catch (e) {
      debugPrint('⚠️ TodayAttendance refresh failed: $e');
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> checkIn() async {
    final prev = state;
    state = const AsyncLoading<CheckInOutRecord>().copyWithPrevious(prev);
    
    try {
      final record = await _repository.checkIn()
          .timeout(const Duration(seconds: 15));
      state = AsyncData(record);
      _ref.invalidate(attendanceMonthProvider(DateTime.now()));
    } catch (e) {
      debugPrint('⚠️ Check-in failed: $e');
      
      if (e is AppFailure) {
        rethrow;
      }
      
      throw const AppFailure('Check-in failed. Please try again.');
    }
  }

  Future<void> checkOut() async {
    final prev = state;
    state = const AsyncLoading<CheckInOutRecord>().copyWithPrevious(prev);
    
    try {
      final record = await _repository.checkOut()
          .timeout(const Duration(seconds: 15));
      state = AsyncData(record);
      _ref.invalidate(attendanceMonthProvider(DateTime.now()));
    } catch (e) {
      debugPrint('⚠️ Check-out failed: $e');
      
      if (e is AppFailure) {
        rethrow;
      }
      
      throw const AppFailure('Check-out failed. Please try again.');
    }
  }
}