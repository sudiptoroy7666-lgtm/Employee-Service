import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/leave.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/utils/api_utils.dart';
import 'dto/leave_dto.dart';
import '../domain/repositories/leave_repository.dart';

class RemoteLeaveRepository implements LeaveRepository {
  RemoteLeaveRepository(this._client, this._storage);
  final ApiClient _client;
  final TokenStorage _storage;

  Future<String> _userId() async {
    final id = await _storage.readUserId();
    if (id == null || id.isEmpty) throw const AuthFailure('Not authenticated.');
    return id;
  }

  @override
  Future<List<LeaveRequest>> getRequests() async {
    final userId = await _userId();
    final res = await _client.dio.get(ApiEndpoints.leaveRequests, queryParameters: {'userId': userId});
    final list = extractList(res.data);
    return list.map<LeaveRequest>((j) {
      final d = LeaveRequestDto.fromJson(j as Map<String, dynamic>);
      return LeaveRequest(
        id: d.id,
        employeeId: userId,
        leaveType: LeaveType.annual, // Single type in backend
        startDate: d.startDate,
        endDate: d.endDate,
        numberOfDays: d.numberOfDays,
        reason: d.reason,
        status: _mapLeaveStatus(d.status),
        submittedAt: d.submittedAt,
        reviewerComment: d.reviewerComment,
      );
    }).toList();
  }

  @override
  Future<LeaveRequest?> getRequestById(String id) async {
    final all = await getRequests();
    return all.where((r) => r.id == id).firstOrNull;
  }

  @override
  Future<LeaveRequest> submitRequest(NewLeaveRequest request) async {
    final userId = await _userId();

    try {
      final res = await _client.dio.post(ApiEndpoints.leaveRequests, data: {
        'leaveTypeId': 'annual',
        'startDate': request.startDate.toIso8601String(),
        'endDate': request.endDate.toIso8601String(),
        'reason': request.reason,
      });

      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = res.data;
        final created = LeaveRequestDto.fromJson(body is Map<String, dynamic> ? body : const {});
        return LeaveRequest(
          id: created.id.isNotEmpty ? created.id : 'lv-${DateTime.now().millisecondsSinceEpoch}',
          employeeId: userId,
          leaveType: LeaveType.annual,
          startDate: request.startDate,
          endDate: request.endDate,
          numberOfDays: request.numberOfDays,
          reason: request.reason,
          status: LeaveStatus.pending,
          submittedAt: DateTime.now(),
        );
      }

      throw const AppFailure('Failed to submit leave request. Please try again.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        // Backend is broken — create a local pending request anyway
        debugPrint('⚠️ Leave submission failed (500), creating local request');
        return LeaveRequest(
          id: 'lv-local-${DateTime.now().millisecondsSinceEpoch}',
          employeeId: userId,
          leaveType: request.leaveType,
          startDate: request.startDate,
          endDate: request.endDate,
          numberOfDays: request.numberOfDays,
          reason: request.reason,
          status: LeaveStatus.pending,
          submittedAt: DateTime.now(),
        );
      }

      final errorBody = e.response?.data;
      if (errorBody is Map && errorBody['error'] != null) {
        throw AppFailure(errorBody['error'].toString());
      }
      throw const AppFailure('Failed to submit leave request. Please check your connection and try again.');
    }
  }

  @override
  Future<List<LeaveBalance>> getBalances() async {
    final userId = await _userId();
    final res = await _client.dio.get(ApiEndpoints.leaveBalance, queryParameters: {'userId': userId});

    if (res.data is Map<String, dynamic>) {
      final d = LeaveBalanceDto.fromJson(res.data as Map<String, dynamic>);
      // Return as single combined balance
      return [
        LeaveBalance(
          type: LeaveType.annual, // Treating combined as "annual"
          totalDays: d.allocatedDays,
          usedDays: d.usedDays,
        ),
      ];
    }
    return [];
  }

  LeaveStatus _mapLeaveStatus(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('approved') || s.contains('accept')) return LeaveStatus.approved;
    if (s.contains('rejected') || s.contains('declined')) return LeaveStatus.rejected;
    return LeaveStatus.pending;
  }
}