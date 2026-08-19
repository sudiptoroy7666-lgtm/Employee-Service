import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_collection_repository.dart';
import '../../domain/models/collection.dart';
import '../../domain/repositories/collection_repository.dart';

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return RemoteCollectionRepository(ref.read(apiClientProvider));
}, name: 'collectionRepository');

final collectionsProvider = FutureProvider.autoDispose<List<Collection>>((ref) {
  final repo = ref.watch(collectionRepositoryProvider);
  return repo.getCollections();
}, name: 'collections');
