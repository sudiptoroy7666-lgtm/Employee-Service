import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/errors/failures.dart';
import '../../data/remote_lead_repository.dart';
import '../../domain/models/lead.dart';
import '../../domain/repositories/lead_repository.dart';

final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return RemoteLeadRepository(ref.read(apiClientProvider));
}, name: 'leadRepository');

final leadsProvider = FutureProvider.autoDispose<List<Lead>>((ref) {
  final repo = ref.watch(leadRepositoryProvider);
  return repo.getLeads();
}, name: 'leads');

final leadFilterProvider = StateProvider<LeadStatus?>((ref) => null);

final filteredLeadsProvider = Provider.autoDispose<List<Lead>>((ref) {
  final leads = ref.watch(leadsProvider).valueOrNull ?? [];
  final filter = ref.watch(leadFilterProvider);

  if (filter == null) return leads;
  return leads.where((l) => l.status == filter).toList();
});

final createLeadControllerProvider = StateNotifierProvider<CreateLeadController, AsyncValue<Lead?>>(
  (ref) => CreateLeadController(ref),
);

class CreateLeadController extends StateNotifier<AsyncValue<Lead?>> {
  final Ref _ref;

  CreateLeadController(this._ref) : super(const AsyncData(null));

  Future<void> submit({
    required String name,
    required String contact,
    String? company,
    int? seedInterestId,
    int? sourceId,
    String? notes,
  }) async {
    state = const AsyncLoading();

    try {
      if (name.trim().isEmpty) {
        throw const AppFailure('Lead name is required.');
      }
      if (contact.trim().isEmpty) {
        throw const AppFailure('Contact number is required.');
      }

      final lead = Lead(
        id: '',
        name: name.trim(),
        contact: contact.trim(),
        company: company?.trim().isEmpty == true ? null : company?.trim(),
        seedInterestId: seedInterestId,
        sourceId: sourceId,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      );

      final repo = _ref.read(leadRepositoryProvider);
      final created = await repo.createLead(lead);

      state = AsyncData(created);
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
