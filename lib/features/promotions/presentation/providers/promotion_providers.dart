import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../orders/domain/models/product.dart';
import '../../data/remote_promotion_repository.dart';
import '../../domain/models/promotion.dart';
import '../../domain/repositories/promotion_repository.dart';

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return RemotePromotionRepository(ref.read(apiClientProvider));
}, name: 'promotionRepository');

final promotionsProvider = FutureProvider.autoDispose<List<Promotion>>((ref) {
  final repo = ref.watch(promotionRepositoryProvider);
  return repo.getPromotions();
}, name: 'promotions');

final promotionProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  final repo = ref.watch(promotionRepositoryProvider);
  return repo.getProducts();
}, name: 'promotionProducts');
