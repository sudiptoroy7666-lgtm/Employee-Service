import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class OfflineSyncService {
  static const _pendingKey = 'offline.pending_operations';

  static Future<void> queueOperation(OfflineOperation operation) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await _loadPending(prefs);
    pending.add(operation.toJson());
    await prefs.setString(_pendingKey, jsonEncode(pending));
    debugPrint('📦 Queued offline operation: ${operation.type} (${operation.endpoint})');
  }

  static Future<SyncResult> processPending({Dio? dio}) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return SyncResult(success: 0, failed: 0, message: 'Still offline');
    }

    final prefs = await SharedPreferences.getInstance();
    final pending = await _loadPending(prefs);

    if (pending.isEmpty) {
      return SyncResult(success: 0, failed: 0, message: 'No pending operations');
    }

    int success = 0;
    int failed = 0;
    final failedOps = <Map<String, dynamic>>[];

    for (final opJson in pending) {
      try {
        final operation = OfflineOperation.fromJson(opJson);

        if (dio != null) {
          await _replayRequest(dio, operation);
        } else {
          await Future.delayed(const Duration(milliseconds: 500));
        }

        success++;
        debugPrint('✅ Synced: ${operation.type} (${operation.endpoint})');
      } catch (e) {
        failed++;
        failedOps.add(opJson);
        debugPrint('❌ Failed to sync: $e');
      }
    }

    if (failedOps.isNotEmpty) {
      await prefs.setString(_pendingKey, jsonEncode(failedOps));
    } else {
      await prefs.remove(_pendingKey);
    }

    return SyncResult(
      success: success,
      failed: failed,
      message: 'Synced $success operations${failed > 0 ? ', $failed failed' : ''}',
    );
  }

  static Future<void> _replayRequest(Dio dio, OfflineOperation operation) async {
    final options = Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    switch (operation.method.toUpperCase()) {
      case 'POST':
        await dio.post(
          operation.endpoint,
          data: operation.body,
          options: options,
        );
        break;
      case 'PUT':
        await dio.put(
          operation.endpoint,
          data: operation.body,
          options: options,
        );
        break;
      case 'PATCH':
        await dio.patch(
          operation.endpoint,
          data: operation.body,
          options: options,
        );
        break;
      case 'DELETE':
        await dio.delete(
          operation.endpoint,
          options: options,
        );
        break;
      default:
        throw Exception('Unsupported HTTP method: ${operation.method}');
    }
  }

  static Future<List<Map<String, dynamic>>> _loadPending(SharedPreferences prefs) async {
    final raw = prefs.getString(_pendingKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<int> getPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await _loadPending(prefs);
    return pending.length;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingKey);
  }
}

class OfflineOperation {
  final String id;
  final String type;
  final String endpoint;
  final String method;
  final Map<String, dynamic>? body;
  final DateTime createdAt;
  final int retryCount;

  OfflineOperation({
    required this.type,
    required this.endpoint,
    required this.method,
    this.body,
    this.retryCount = 0,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'endpoint': endpoint,
        'method': method,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      type: json['type'] as String,
      endpoint: json['endpoint'] as String? ?? '',
      method: json['method'] as String? ?? 'POST',
      body: json['body'] as Map<String, dynamic>?,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

class SyncResult {
  final int success;
  final int failed;
  final String message;

  SyncResult({
    required this.success,
    required this.failed,
    required this.message,
  });
}
