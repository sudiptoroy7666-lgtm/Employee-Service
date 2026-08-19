import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../leads/presentation/providers/lead_providers.dart';
import '../../data/remote_followup_repository.dart';
import '../../domain/models/followup.dart';
import '../../domain/repositories/followup_repository.dart';

final followUpRepositoryProvider = Provider<FollowUpRepository>((ref) {
  return RemoteFollowUpRepository(ref.read(apiClientProvider));
}, name: 'followUpRepository');

final followUpsProvider = FutureProvider.autoDispose<List<FollowUp>>((ref) {
  final repo = ref.watch(followUpRepositoryProvider);
  return repo.getFollowUps();
}, name: 'followUps');

final createFollowUpControllerProvider = StateNotifierProvider<CreateFollowUpController, AsyncValue<FollowUp?>>(
  (ref) => CreateFollowUpController(ref),
);

class CreateFollowUpController extends StateNotifier<AsyncValue<FollowUp?>> {
  final Ref _ref;

  CreateFollowUpController(this._ref) : super(const AsyncData(null));

  Future<void> submit({
    required String leadId,
    required DateTime followUpDate,
    String? notes,
    FollowUpOutcome? outcome,
  }) async {
    state = const AsyncLoading();

    try {
      if (leadId.isEmpty) {
        throw const AppFailure('Please select a lead.');
      }

      final followUp = FollowUp(
        id: '',
        leadId: leadId,
        followUpDate: followUpDate,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        outcome: outcome,
      );

      final repo = _ref.read(followUpRepositoryProvider);
      final created = await repo.createFollowUp(followUp);

      state = AsyncData(created);
      _ref.invalidate(followUpsProvider);
      _ref.invalidate(leadsProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
