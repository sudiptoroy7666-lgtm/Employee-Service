import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_client_repository.dart';
import '../../domain/models/marketing_client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/services/client_product_permission_service.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return RemoteClientRepository(ref.read(apiClientProvider));
}, name: 'clientRepository');

final clientsProvider = FutureProvider.autoDispose<List<MarketingClient>>((ref) {
  final repo = ref.watch(clientRepositoryProvider);
  return repo.getClients();
}, name: 'clients');

final clientProductPermissionServiceProvider = Provider(
  (ref) => ClientProductPermissionService(),
  name: 'clientProductPermissionService',
);
