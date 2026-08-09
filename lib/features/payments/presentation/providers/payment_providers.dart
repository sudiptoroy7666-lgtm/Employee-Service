import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/payment.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_payment_repository.dart';
import '../../domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => RemotePaymentRepository(
    ref.read(apiClientProvider),
    ref.read(tokenStorageProvider),
  ),
  name: 'paymentRepository',
);

final paymentsProvider = FutureProvider.autoDispose<List<PaymentBill>>((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getPayments();
}, name: 'payments');

final paymentDetailProvider = FutureProvider.family.autoDispose<PaymentBill, String>((ref, id) {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getPaymentById(id);
}, name: 'paymentDetail');
