import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/states.dart';
import '../providers/payment_providers.dart';
import '../widgets/payment_card.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: paymentsAsync.when(
         loading: () => ListView(padding: const EdgeInsets.all(16), children: const [LoadingSkeleton(blocks: 3)]),
        error: (e, _) => ErrorStateWidget(error: e, onRetry: () => ref.invalidate(paymentsProvider)),
        data: (payments) {
          if (payments.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.payments_outlined,
              title: 'No payments yet',
              message: 'Your payment history will appear here once payroll runs.',
            );
          }
          final latest = payments.first;
          final history = payments.skip(1).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(paymentsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Reveal(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.raised,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: -30,
                          top: -40,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 22),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Latest Payment',
                                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.2),
                                ),
                                const Spacer(),
                                PaymentStatusChip(status: latest.status, onDark: true),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              Fmt.monthYear(latest.paymentMonth),
                              style: GoogleFontsSora.size18.copyWith(fontSize: 16, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Fmt.money(latest.netAmount, latest.currency),
                              style: GoogleFontsSora.size22.copyWith(fontSize: 34, color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 13, color: Colors.white.withValues(alpha: 0.6)),
                                const SizedBox(width: 6),
                                Text(
                                  latest.paymentDate != null
                                      ? 'Paid on ${Fmt.dateMedium(latest.paymentDate!)}'
                                      : 'Scheduled — payroll in progress',
                                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SectionHeader(title: 'Payment History'),
                if (history.isEmpty)
                  const EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'No earlier payments',
                    message: 'Older payment records will appear here.',
                  )
                else
                  ...List.generate(history.length, (i) {
                    final bill = history[i];
                    return Reveal(
                      delay: Duration(milliseconds: 100 + i * 45),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PaymentCard(bill: bill, onTap: () => context.push('/payments/detail/${bill.id}')),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}