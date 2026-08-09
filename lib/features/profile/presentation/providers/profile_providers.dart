import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/employee.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_profile_repository.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => RemoteProfileRepository(ref.read(apiClientProvider)),
  name: 'profileRepository',
);

/// The logged-in employee's profile, fetched from `/api/employees/me`.
final profileProvider = FutureProvider.autoDispose<Employee>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile();
}, name: 'profile');