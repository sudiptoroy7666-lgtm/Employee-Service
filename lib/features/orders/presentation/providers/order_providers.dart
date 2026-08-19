import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_order_repository.dart';
import '../../domain/models/order.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
      (ref) {
    return RemoteOrderRepository(
      ref.read(apiClientProvider),
    );
  },
  name: 'orderRepository',
);

final ordersProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrders();
}, name: 'orders');

final orderDetailProvider = FutureProvider.family.autoDispose<Order, String>((ref, id) async {
  final repo = ref.watch(orderRepositoryProvider);
  final order = await repo.getOrderById(id);
  if (order == null) throw const NotFoundFailure('Order not found.');
  return order;
}, name: 'orderDetail');

// FIX: Use the SAME repository that has the correct getProducts() parsing logic
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getProducts();
}, name: 'products');

final createOrderProvider = StateNotifierProvider<CreateOrderController, AsyncValue<Order?>>(
      (ref) {
    return CreateOrderController(ref.watch(orderRepositoryProvider));
  },
  name: 'createOrder',
);

class CreateOrderController extends StateNotifier<AsyncValue<Order?>> {
  CreateOrderController(this._repository) : super(const AsyncData(null));

  final OrderRepository _repository;

  Future<void> submit(Order order) async {
    state = const AsyncLoading();
    try {
      final created = await _repository.createOrder(order);
      state = AsyncData(created);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}