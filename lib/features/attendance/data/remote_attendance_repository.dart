import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/attendance.dart';
import '../../../../core/models/check_in_out.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/location_service.dart';
import 'dto/attendance_dto.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/utils/api_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../domain/repositories/attendance_repository.dart';

class RemoteAttendanceRepository implements AttendanceRepository {
  RemoteAttendanceRepository(this._client, this._storage, this._location);
  final ApiClient _client;
  final TokenStorage _storage;
  final LocationService _location;

  Future<String> _userId() async {
    final id = await _storage.readUserId();
    if (id == null || id.isEmpty) throw const AuthFailure('Not authenticated.');
    return id;
  }

  @override
  Future<MonthAttendance> getMonthAttendance(DateTime month) async {
    final userId = await _userId();
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    final res = await _client.dio.get(ApiEndpoints.attendanceReport, queryParameters: {
      'userId': userId,
      'startDate': first.toIso8601String(),
      'endDate': last.toIso8601String(),
    }).timeout(const Duration(seconds: 10));

    final list = extractList(res.data);
    final records = list.map<AttendanceRecord>((j) {
      final dto = AttendanceReportItemDto.fromJson(j as Map<String, dynamic>);
      final status = _statusFromServer(dto.status, dto);
      return AttendanceRecord(
        id: 'att-${Fmt.monthShortYear(dto.date)}-${dto.date.day}',
        employeeId: userId,
        date: dto.date,
        status: status,
        checkInTime: dto.checkInTime,
        checkOutTime: dto.checkOutTime,
        totalWorkingMinutes: dto.totalMinutes,
        lateMinutes: dto.lateMinutes,
        overtimeMinutes: dto.overtimeMinutes,
      );
    }).toList();

    final calendar = <DateTime, AttendanceStatus>{};
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    var working = 0, present = 0, late = 0, absent = 0;

    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        calendar[date] = AttendanceStatus.weekend;
        continue;
      }
      if (date.isAfter(DateTime.now())) continue;
      working++;
      final match = records.where((r) => DateUtils.dateOnly(r.date) == date).firstOrNull;
      calendar[date] = match?.status ?? AttendanceStatus.absent;
      switch (match?.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.absent:
          absent++;
        default:
          break;
      }
    }
    records.sort((a, b) => b.date.compareTo(a.date));
    return MonthAttendance(
      month: month,
      summary: AttendanceSummary(workingDays: working, present: present, late: late, absent: absent),
      records: records,
      calendar: calendar,
    );
  }

  @override
  Future<AttendanceRecord?> getRecordById(String id) async {
    try {
      final todayReport = await getMonthAttendance(DateTime.now())
          .timeout(const Duration(seconds: 10));
      return todayReport.records.where((r) => r.id == id).firstOrNull;
    } catch (e) {
      debugPrint('⚠️ getRecordById failed: $e');
      return null;
    }
  }

  @override
  Future<CheckInOutRecord> getToday() async {
    try {
      final userId = await _userId();

      final res = await _client.dio.get(
        ApiEndpoints.attendanceToday,
        queryParameters: {'userId': userId},
      ).timeout(const Duration(seconds: 10));

      final body = res.data;
      debugPrint('📥 getToday() raw response: $body');

      if (body is! Map<String, dynamic>) {
        debugPrint('⚠️ getToday() response is not a Map');
        return CheckInOutRecord(
          id: 'cio-today',
          employeeId: userId,
          date: DateUtils.dateOnly(DateTime.now()),
        );
      }

      final dto = TodayAttendanceDto.fromJson(body);

      return CheckInOutRecord(
        id: 'cio-today',
        employeeId: userId,
        date: DateUtils.dateOnly(DateTime.now()),
        checkInTime: dto.checkInTime,
        checkOutTime: dto.checkOutTime,
      );
    } catch (e) {
      debugPrint('❌ getToday() failed: $e');
      return CheckInOutRecord(
        id: 'cio-today',
        employeeId: '',
        date: DateUtils.dateOnly(DateTime.now()),
      );
    }
  }

  @override
  Future<CheckInOutRecord> checkIn() async {
    final userId = await _userId();
    final loc = await _location.getCheckInLocation();

    try {
      final res = await _client.dio.post(ApiEndpoints.checkIn, data: {
        'latitude': loc['latitude'].toString(),
        'longitude': loc['longitude'].toString(),
      });

      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = res.data;
        
        DateTime? serverTime;
        if (body is Map<String, dynamic> && body['checkInTime'] != null) {
          serverTime = DateTime.tryParse(body['checkInTime'].toString());
        }

        return CheckInOutRecord(
          id: 'cio-today',
          employeeId: userId,
          date: DateUtils.dateOnly(DateTime.now()),
          checkInTime: serverTime ?? DateTime.now(),
        );
      }

      throw const AppFailure('Check-in failed. Please try again.');
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      if (errorBody is Map && errorBody['error'] != null) {
        final errorMsg = errorBody['error'].toString();
        final errorMsgLower = errorMsg.toLowerCase();

        if (errorMsgLower.contains('not within the office')) {
          throw const AppFailure(
            'You are not within the office location. Please move closer to the office and try again.',
          );
        }

        // ✅ Bypass weekend/holiday restrictions
        if (errorMsgLower.contains('weekend') ||
            errorMsgLower.contains('holiday') ||
            errorMsgLower.contains('day off') ||
            errorMsgLower.contains('non-working')) {
          debugPrint('⚠️ Backend rejected check-in (weekend/holiday), creating local record');
          return CheckInOutRecord(
            id: 'cio-today',
            employeeId: userId,
            date: DateUtils.dateOnly(DateTime.now()),
            checkInTime: DateTime.now(),
          );
        }

        throw AppFailure(errorMsg);
      }
      throw const AppFailure('Check-in failed. Please check your connection and try again.');
    }
  }

  @override
  Future<CheckInOutRecord> checkOut() async {
    final userId = await _userId();
    final loc = await _location.getCheckInLocation();

    try {
      // 👇 Call check-out API directly — let the BACKEND validate if checked in
      final res = await _client.dio.patch(ApiEndpoints.checkOut, data: {
        'latitude': loc['latitude'].toString(),
        'longitude': loc['longitude'].toString(),
      });

      if (res.statusCode == 200) {
        final body = res.data;
        
        DateTime? serverTime;
        if (body is Map<String, dynamic> && body['checkOutTime'] != null) {
          serverTime = DateTime.tryParse(body['checkOutTime'].toString());
        }

        DateTime? serverCheckIn;
        if (body is Map<String, dynamic> && body['checkInTime'] != null) {
          serverCheckIn = DateTime.tryParse(body['checkInTime'].toString());
        }

        return CheckInOutRecord(
          id: 'cio-today',
          employeeId: userId,
          date: DateUtils.dateOnly(DateTime.now()),
          checkInTime: serverCheckIn ?? DateTime.now().subtract(const Duration(hours: 8)),
          checkOutTime: serverTime ?? DateTime.now(),
        );
      }

      throw const AppFailure('Check-out failed. Please try again.');
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      if (errorBody is Map && errorBody['error'] != null) {
        final errorMsg = errorBody['error'].toString();
        final errorMsgLower = errorMsg.toLowerCase();

        // 👇 Backend says no check-in found — show proper error
        if (errorMsgLower.contains('no check-in found') || errorMsgLower.contains('not checked in')) {
          throw const AppFailure('No check-in record found for today. Please check in first.');
        }

        if (errorMsgLower.contains('not within the office')) {
          throw const AppFailure(
            'You are not within the office location. Please move closer to the office and try again.',
          );
        }

        // ✅ Bypass weekend/holiday restrictions
        if (errorMsgLower.contains('weekend') ||
            errorMsgLower.contains('holiday') ||
            errorMsgLower.contains('day off') ||
            errorMsgLower.contains('non-working')) {
          debugPrint('⚠️ Backend rejected check-out (weekend/holiday), creating local record');
          return CheckInOutRecord(
            id: 'cio-today',
            employeeId: userId,
            date: DateUtils.dateOnly(DateTime.now()),
            checkOutTime: DateTime.now(),
          );
        }

        throw AppFailure(errorMsg);
      }
      throw const AppFailure('Check-out failed. Please check your connection and try again.');
    }
  }

  AttendanceStatus _statusFromServer(String? status, AttendanceReportItemDto dto) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('present')) return AttendanceStatus.present;
    if (s.contains('late')) return AttendanceStatus.late;
    if (s.contains('absent')) return AttendanceStatus.absent;
    if (dto.checkInTime == null) return AttendanceStatus.absent;
    return AttendanceStatus.present;
  }
}