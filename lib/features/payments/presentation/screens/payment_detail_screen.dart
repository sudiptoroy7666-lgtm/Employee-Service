import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/payment.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../../core/widgets/states.dart';
import '../providers/payment_providers.dart';

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({super.key, required this.billId});
  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final billAsync = ref.watch(paymentDetailProvider(billId));

    return AppScaffold(
      title: 'Payment Detail',
      body: billAsync.when(
         loading: () => ListView(padding: const EdgeInsets.all(16), children: const [LoadingSkeleton(blocks: 2)]),
        error: (e, _) => ErrorStateWidget(error: e, onRetry: () => ref.invalidate(paymentDetailProvider(billId))),
        data: (bill) {
          final rows = <Widget>[
            _AmountRow(label: 'Gross Amount', amount: bill.grossAmount, currency: bill.currency),
            if (bill.allowances != null)
              _AmountRow(label: 'Allowances', amount: bill.allowances!, currency: bill.currency, positive: true),
            if (bill.bonuses != null)
              _AmountRow(label: 'Bonuses', amount: bill.bonuses!, currency: bill.currency, positive: true),
            if (bill.deductions != null)
              _AmountRow(label: 'Deductions', amount: bill.deductions!, currency: bill.currency, negative: true),
            if (bill.tax != null) _AmountRow(label: 'Tax', amount: bill.tax!, currency: bill.currency, negative: true),
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Reveal(
                child: AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Fmt.monthYear(bill.paymentMonth), style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 4),
                            Text('Payment breakdown', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      PaymentStatusChip(status: bill.status),
                    ],
                  ),
                ),
              ),
              if (bill.status == PaymentStatus.failed && bill.notes != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.danger),
                      const SizedBox(width: 10),
                      Expanded(child: Text(bill.notes!, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
              ] else if (bill.notes != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(child: Text(bill.notes!, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Reveal(
                delay: const Duration(milliseconds: 80),
                child: AppCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0) const Divider(height: 20),
                        rows[i],
                      ],
                      const Divider(height: 24),
                      Row(
                        children: [
                          Text('Net Amount', style: theme.textTheme.titleMedium),
                          const Spacer(),
                          Text(
                            Fmt.money(bill.netAmount, bill.currency),
                            style: GoogleFontsSora.size22.copyWith(fontSize: 21, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: const Duration(milliseconds: 140),
                child: AppCard(
                  child: Column(
                    children: [
                      InfoRow(label: 'Payment date', value: bill.paymentDate != null ? Fmt.dateMedium(bill.paymentDate!) : '—'),
                      const Divider(height: 18),
                      InfoRow(label: 'Reference ID', value: bill.referenceId ?? '—'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'View Payslip',
                icon: Icons.picture_as_pdf_outlined,
                onPressed: () => showInfoSheet(
                  context,
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'Payslip coming soon',
                  message: 'Payslip documents are published by HR. This action will open your payslip as soon as the backend enables it.',
                ),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Download Statement',
                icon: Icons.download_outlined,
                onPressed: () => AppSnack.info(context, 'Statement downloads will be available in a future release.'),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.amount, required this.currency, this.positive = false, this.negative = false});
  final String label;
  final double amount;
  final String currency;
  final bool positive;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = positive ? AppColors.success : negative ? AppColors.danger : theme.textTheme.bodyLarge?.color;
    final sign = positive ? '+' : negative ? '−' : '';
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text('$sign${Fmt.money(amount, currency)}', style: theme.textTheme.titleSmall?.copyWith(color: color)),
      ],
    );
  }
}