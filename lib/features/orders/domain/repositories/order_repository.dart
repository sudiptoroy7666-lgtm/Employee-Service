import '../models/order.dart';
import '../models/product.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order?> getOrderById(String id);
  Future<Order> createOrder(Order order);
  Future<List<Product>> getProducts();
}
