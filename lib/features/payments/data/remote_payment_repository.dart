import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/payment.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/utils/api_utils.dart';
import 'dto/payment_dto.dart';
import '../domain/repositories/payment_repository.dart';

class RemotePaymentRepository implements PaymentRepository {
  RemotePaymentRepository(this._client, this._storage);
  final ApiClient _client;
  final TokenStorage _storage;

  Future<String> _userId() async {
    final id = await _storage.readUserId();
    if (id == null || id.isEmpty) throw const AuthFailure('Not authenticated.');
    return id;
  }

  @override
  Future<List<PaymentBill>> getPayments() async {
    final userId = await _userId();
    final res = await _client.dio.get(ApiEndpoints.payroll, queryParameters: {'userId': userId, 'limit': 24})
        .timeout(const Duration(seconds: 10));
    final list = extractList(res.data);
    final bills = list.map<PaymentBill>((j) {
      final d = PaymentBillDto.fromJson(j as Map<String, dynamic>);
      return PaymentBill(
        id: d.id,
        employeeId: userId,
        paymentMonth: DateTime(d.year, d.month), // Numeric month
        currency: 'BDT', // Backend is in Bangladesh (Taka)
        grossAmount: d.grossAmount,
        allowances: 0, // Not provided
        bonuses: 0,
        deductions: d.unpaidDeduction,
        tax: 0, // Not provided
        netAmount: d.netAmount,
        status: _mapStatus(d.status),
        paymentDate: d.paymentDate,
        referenceId: null,
      );
    }).toList();
    bills.sort((a, b) => b.paymentMonth.compareTo(a.paymentMonth));
    return bills;
  }

  @override
  Future<PaymentBill> getPaymentById(String id) async {
    final all = await getPayments();
    final found = all.where((p) => p.id == id).firstOrNull;
    if (found == null) throw const NotFoundFailure('Payment not found.');
    return found;
  }

  PaymentStatus _mapStatus(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('paid') || s.contains('completed')) return PaymentStatus.paid;
    if (s.contains('process')) return PaymentStatus.processing;
    if (s.contains('fail')) return PaymentStatus.failed;
    return PaymentStatus.pending;
  }
}