import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_visit_repository.dart';
import '../../domain/models/visit.dart';
import '../../domain/repositories/visit_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  return RemoteVisitRepository(ref.read(apiClientProvider));
}, name: 'visitRepository');

final visitsProvider = FutureProvider.autoDispose<List<Visit>>((ref) {
  final repo = ref.watch(visitRepositoryProvider);
  return repo.getVisits();
}, name: 'visits');

// Day Management
class DayState {
  final bool isDayStarted;
  final DateTime? startTime;
  final DateTime? endTime;

  DayState({this.isDayStarted = false, this.startTime, this.endTime});
  
  Map<String, dynamic> toJson() => {
    'isDayStarted': isDayStarted,
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
  };

  factory DayState.fromJson(Map<String, dynamic> json) => DayState(
    isDayStarted: json['isDayStarted'] as bool? ?? false,
    startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
  );
}

final dayManagementProvider = StateNotifierProvider<DayManagementController, DayState>(
  (ref) => DayManagementController(),
);

class DayManagementController extends StateNotifier<DayState> {
  static const _key = 'marketing.day.state';

  DayManagementController() : super(DayState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      state = DayState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> startDay() async {
    state = DayState(isDayStarted: true, startTime: DateTime.now());
    await _save();
  }

  Future<void> endDay() async {
    state = DayState(
      isDayStarted: false,
      startTime: state.startTime,
      endTime: DateTime.now(),
    );
    await _save();
  }
}
