import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_stakeholder_repository.dart';
import '../../domain/models/marketing_client.dart';
import '../../domain/repositories/stakeholder_repository.dart';

final stakeholderRepositoryProvider = Provider<StakeholderRepository>((ref) {
  return RemoteStakeholderRepository(ref.read(apiClientProvider));
}, name: 'stakeholderRepository');

final stakeholdersProvider = FutureProvider.autoDispose<List<MarketingClient>>((ref) {
  final repo = ref.watch(stakeholderRepositoryProvider);
  return repo.getStakeholders();
}, name: 'stakeholders');

final stakeholderSearchProvider = StateProvider<String>((ref) => '');

final filteredStakeholdersProvider = Provider.autoDispose<List<MarketingClient>>((ref) {
  final stakeholders = ref.watch(stakeholdersProvider).valueOrNull ?? [];
  final search = ref.watch(stakeholderSearchProvider).toLowerCase().trim();

  if (search.isEmpty) return stakeholders;

  return stakeholders.where((s) {
    return s.name.toLowerCase().contains(search) ||
        (s.companyName?.toLowerCase().contains(search) ?? false) ||
        s.contact.contains(search) ||
        (s.address?.toLowerCase().contains(search) ?? false);
  }).toList();
});

final stakeholderByIdProvider = FutureProvider.family.autoDispose<MarketingClient?, String>(
  (ref, id) {
    final repo = ref.watch(stakeholderRepositoryProvider);
    return repo.getStakeholderById(id);
  },
  name: 'stakeholderById',
);
