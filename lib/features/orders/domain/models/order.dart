import 'order_item.dart';
import 'order_status.dart';

class Order {
  final String id;
  final String orderNumber;
  final String clientId;
  final String clientName;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final OrderStatus status;
  final double totalAmount;
  final List<OrderItem> items;
  final String supervisorName;
  final String notes;
  final bool isLocalOnly;

  Order({
    required this.id,
    required this.orderNumber,
    required this.clientId,
    required this.clientName,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.supervisorName,
    this.notes = '',
    this.isLocalOnly = false,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
