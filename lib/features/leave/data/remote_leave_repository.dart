import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/leave.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/utils/api_utils.dart';
import 'dto/leave_dto.dart';
import '../domain/repositories/leave_repository.dart';
import 'leave_local_cache.dart';

class RemoteLeaveRepository implements LeaveRepository {
  RemoteLeaveRepository(this._client, this._storage);
  final ApiClient _client;
  final TokenStorage _storage;
  static const _uuid = Uuid();

  Future<String> _userId() async {
    final id = await _storage.readUserId();
    if (id == null || id.isEmpty) throw const AuthFailure('Not authenticated.');
    return id;
  }

  @override
  Future<List<LeaveRequest>> getRequests() async {
    final userId = await _userId();
    try {
      final res = await _client.dio.get(ApiEndpoints.leaveRequests, queryParameters: {'userId': userId})
          .timeout(const Duration(seconds: 10));
      final list = extractList(res.data);
      final serverRequests = list.map<LeaveRequest>((j) {
        final d = LeaveRequestDto.fromJson(j as Map<String, dynamic>);
        return LeaveRequest(
          id: d.id,
          employeeId: userId,
          leaveType: LeaveType.annual,
          startDate: d.startDate,
          endDate: d.endDate,
          numberOfDays: d.numberOfDays,
          reason: d.reason,
          status: _mapLeaveStatus(d.status),
          submittedAt: d.submittedAt,
          reviewerComment: d.reviewerComment,
        );
      }).toList();

      final localRequests = await LeaveLocalCache.loadRequests();
      final merged = <LeaveRequest>[];
      final seen = <String>{};

      for (final r in serverRequests) {
        merged.add(r);
        seen.add(r.id);
      }

      for (final r in localRequests) {
        if (!seen.contains(r.id)) {
          merged.add(r);
        }
      }

      merged.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return merged;
    } catch (e) {
      debugPrint('⚠️ getRequests() server failed, falling back to local cache: $e');
      final localRequests = await LeaveLocalCache.loadRequests();
      localRequests.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return localRequests;
    }
  }

  @override
  Future<LeaveRequest?> getRequestById(String id) async {
    final local = await LeaveLocalCache.loadRequests();
    final localMatch = local.where((r) => r.id == id).firstOrNull;
    if (localMatch != null) return localMatch;

    try {
      final all = await getRequests().timeout(const Duration(seconds: 10));
      return all.where((r) => r.id == id).firstOrNull;
    } catch (e) {
      debugPrint('⚠️ getRequestById failed: $e');
      return null;
    }
  }

  @override
  Future<LeaveRequest> submitRequest(NewLeaveRequest request) async {
    final userId = await _userId();

    try {
      final res = await _client.dio.post(ApiEndpoints.leaveRequests, data: {
        'requestId': _uuid.v4(),
        'leaveTypeId': 'annual',
        'startDate': request.startDate.toIso8601String(),
        'endDate': request.endDate.toIso8601String(),
        'reason': request.reason,
      }).timeout(const Duration(seconds: 15));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = res.data;
        final created = LeaveRequestDto.fromJson(body is Map<String, dynamic> ? body : const {});
        final leaveRequest = LeaveRequest(
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
        await LeaveLocalCache.addRequest(leaveRequest);
        return leaveRequest;
      }

      throw const AppFailure('Failed to submit leave request. Please try again.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        debugPrint('⚠️ Leave submission failed (500), creating local request');
        final localRequest = LeaveRequest(
          id: 'lv-local-${DateTime.now().millisecondsSinceEpoch}',
          employeeId: userId,
          leaveType: request.leaveType,
          startDate: request.startDate,
          endDate: request.endDate,
          numberOfDays: request.numberOfDays,
          reason: request.reason,
          status: LeaveStatus.pending,
          submittedAt: DateTime.now(),
          isLocalOnly: true,
        );
        await LeaveLocalCache.addRequest(localRequest);
        return localRequest;
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
    final res = await _client.dio.get(ApiEndpoints.leaveBalance, queryParameters: {'userId': userId})
        .timeout(const Duration(seconds: 10));

    if (res.data is Map<String, dynamic>) {
      final d = LeaveBalanceDto.fromJson(res.data as Map<String, dynamic>);
      return [
        LeaveBalance(
          type: LeaveType.annual,
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
