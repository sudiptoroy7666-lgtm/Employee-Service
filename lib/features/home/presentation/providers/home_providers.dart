import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/activity.dart';
import '../../../../core/models/employee.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_home_repository.dart';
import '../../domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => RemoteHomeRepository(
    ref.read(apiClientProvider),
    ref.read(tokenStorageProvider),
  ),
  name: 'homeRepository',
);

/// The logged-in employee's profile, fetched from the backend.
final homeProfileProvider = FutureProvider.autoDispose<Employee>((ref) {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getProfile();
}, name: 'homeProfile');

/// Today's recent activity (check-in / check-out events).
final recentActivitiesProvider = FutureProvider.autoDispose<List<ActivityItem>>((ref) {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getRecentActivities();
}, name: 'recentActivities');