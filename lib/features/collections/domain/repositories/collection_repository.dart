import '../models/collection.dart';

abstract class CollectionRepository {
  Future<List<Collection>> getCollections();
  Future<Collection> createCollection(Collection collection);
  Future<List<Collection>> getCollectionHistory({
    String? stakeholderId,
    int? statusId,
  });
}
