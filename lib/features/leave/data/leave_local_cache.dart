import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/leave.dart';

class LeaveLocalCache {
  static const _key = 'leave.local_requests';

  static Future<void> addRequest(LeaveRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await _readAll(prefs);
    if (existing.any((r) => r.id == request.id)) return;
    existing.add(request);
    await _writeAll(prefs, existing);
  }

  static Future<List<LeaveRequest>> loadRequests() async {
    final prefs = await SharedPreferences.getInstance();
    return _readAll(prefs);
  }

  static Future<void> removeRequest(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await _readAll(prefs);
    existing.removeWhere((r) => r.id == id);
    await _writeAll(prefs, existing);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<List<LeaveRequest>> _readAll(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((j) => _fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _writeAll(SharedPreferences prefs, List<LeaveRequest> requests) async {
    final list = requests.map(_toJson).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  static Map<String, dynamic> _toJson(LeaveRequest r) => {
    'id': r.id,
    'employeeId': r.employeeId,
    'leaveType': r.leaveType.index,
    'startDate': r.startDate.toIso8601String(),
    'endDate': r.endDate.toIso8601String(),
    'numberOfDays': r.numberOfDays,
    'reason': r.reason,
    'status': r.status.index,
    'submittedAt': r.submittedAt.toIso8601String(),
    'reviewerName': r.reviewerName,
    'reviewerComment': r.reviewerComment,
    'reviewedAt': r.reviewedAt?.toIso8601String(),
    'isLocalOnly': r.isLocalOnly,
  };

  static LeaveRequest _fromJson(Map<String, dynamic> j) => LeaveRequest(
    id: j['id'] as String,
    employeeId: j['employeeId'] as String? ?? '',
    leaveType: LeaveType.values[j['leaveType'] as int? ?? 0],
    startDate: DateTime.tryParse(j['startDate'] as String? ?? '') ?? DateTime.now(),
    endDate: DateTime.tryParse(j['endDate'] as String? ?? '') ?? DateTime.now(),
    numberOfDays: j['numberOfDays'] as int? ?? 0,
    reason: j['reason'] as String? ?? '',
    status: LeaveStatus.values[j['status'] as int? ?? 0],
    submittedAt: DateTime.tryParse(j['submittedAt'] as String? ?? '') ?? DateTime.now(),
    reviewerName: j['reviewerName'] as String?,
    reviewerComment: j['reviewerComment'] as String?,
    reviewedAt: j['reviewedAt'] != null ? DateTime.tryParse(j['reviewedAt'] as String) : null,
    isLocalOnly: j['isLocalOnly'] as bool? ?? false,
  );
}
