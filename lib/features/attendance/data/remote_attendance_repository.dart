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
    });

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
    // Re-use the month report — the UI only opens records that exist.
    final todayReport = await getMonthAttendance(DateTime.now());
    return todayReport.records.where((r) => r.id == id).firstOrNull;
  }

  @override
  Future<CheckInOutRecord> getToday() async {
    final userId = await _userId();
    try {
      final res = await _client.dio.get(ApiEndpoints.attendanceToday, queryParameters: {'userId': userId});
      final body = res.data;
      final dto = TodayAttendanceDto.fromJson(body is Map<String, dynamic> ? body : const {});
      return CheckInOutRecord(
        id: 'cio-today',
        employeeId: userId,
        date: DateUtils.dateOnly(DateTime.now()),
        checkInTime: dto.checkInTime,
        checkOutTime: dto.checkOutTime,
      );
    } catch (_) {
      // If the endpoint is unavailable, treat the day as not started.
      return CheckInOutRecord(
        id: 'cio-today',
        employeeId: userId,
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
        'latitude': loc['latitude'].toString(),  // Send as string per backend spec
        'longitude': loc['longitude'].toString(),
      });

      if (res.statusCode == 201 || res.statusCode == 200) {
        return CheckInOutRecord(
          id: 'cio-today',
          employeeId: userId,
          date: DateUtils.dateOnly(DateTime.now()),
          checkInTime: DateTime.now(),
        );
      }

      throw const AppFailure('Check-in failed. Please try again.');
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      if (errorBody is Map && errorBody['error'] != null) {
        final errorMsg = errorBody['error'].toString();

        if (errorMsg.contains('not within the office')) {
          throw const AppFailure(
            'You are not within the office location. Please move closer to the office and try again.',
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
    final current = await getToday();

    if (current.checkInTime == null) {
      throw const AppFailure('You have not checked in today. Please check in first.');
    }

    try {
      final res = await _client.dio.patch(ApiEndpoints.checkOut, data: {
        'latitude': loc['latitude'].toString(),
        'longitude': loc['longitude'].toString(),
      });

      if (res.statusCode == 200) {
        return CheckInOutRecord(
          id: 'cio-today',
          employeeId: userId,
          date: DateUtils.dateOnly(DateTime.now()),
          checkInTime: current.checkInTime,
          checkOutTime: DateTime.now(),
        );
      }

      throw const AppFailure('Check-out failed. Please try again.');
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      if (errorBody is Map && errorBody['error'] != null) {
        final errorMsg = errorBody['error'].toString();

        if (errorMsg.contains('No check-in found')) {
          throw const AppFailure('No check-in record found for today. Please check in first.');
        }

        if (errorMsg.contains('not within the office')) {
          throw const AppFailure(
            'You are not within the office location. Please move closer to the office and try again.',
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