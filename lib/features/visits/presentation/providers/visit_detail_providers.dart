import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/app_providers.dart';
import '../../domain/models/visit.dart';
import 'visit_providers.dart';

final visitDetailProvider = FutureProvider.family.autoDispose<Visit, String>((ref, id) async {
  final repo = ref.watch(visitRepositoryProvider);
  final visit = await repo.getVisitById(id);
  if (visit == null) throw const NotFoundFailure('Visit not found.');
  return visit;
});

final visitCheckInControllerProvider = StateNotifierProvider.autoDispose<VisitCheckInController, AsyncValue<Visit>>(
  (ref) => VisitCheckInController(ref),
);

class VisitCheckInController extends StateNotifier<AsyncValue<Visit>> {
  final Ref _ref;
  VisitCheckInController(this._ref) : super(const AsyncLoading());

  Future<void> checkIn(String visitId) async {
    state = const AsyncLoading();
    try {
      final locationService = _ref.read(locationServiceProvider);
      await locationService.getVisitLocation(requireGps: true); // Validate GPS
      
      final repo = _ref.read(visitRepositoryProvider);
      final updated = await repo.checkInVisit(visitId);
      state = AsyncData(updated);
      _ref.invalidate(visitDetailProvider(visitId));
      _ref.invalidate(visitsProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final visitCheckOutControllerProvider = StateNotifierProvider.autoDispose<VisitCheckOutController, AsyncValue<Visit>>(
  (ref) => VisitCheckOutController(ref),
);

class VisitCheckOutController extends StateNotifier<AsyncValue<Visit>> {
  final Ref _ref;
  VisitCheckOutController(this._ref) : super(const AsyncLoading());

  Future<void> checkOut(String visitId, {String? notes, List<String>? imagePaths}) async {
    state = const AsyncLoading();
    try {
      final locationService = _ref.read(locationServiceProvider);
      await locationService.getVisitLocation(requireGps: true); // Validate GPS
      
      final repo = _ref.read(visitRepositoryProvider);
      final updated = await repo.checkOutVisit(visitId, notes: notes, imagePaths: imagePaths);
      state = AsyncData(updated);
      _ref.invalidate(visitDetailProvider(visitId));
      _ref.invalidate(visitsProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
