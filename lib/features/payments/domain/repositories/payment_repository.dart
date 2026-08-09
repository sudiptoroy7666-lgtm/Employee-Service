import '../../../../core/models/payment.dart';

abstract class PaymentRepository {
  Future<List<PaymentBill>> getPayments();
  Future<PaymentBill> getPaymentById(String id);
}