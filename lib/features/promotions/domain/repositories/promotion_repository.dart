import '../models/promotion.dart';
import '../../../../features/orders/domain/models/product.dart';

abstract class PromotionRepository {
  Future<List<Promotion>> getPromotions();
  Future<Promotion> createPromotion(Promotion promotion);
  Future<List<Product>> getProducts();
}
