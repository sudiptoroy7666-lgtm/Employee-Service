import 'package:flutter/material.dart';

import '../../../../core/models/payment.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/chips.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key, required this.bill, required this.onTap});
  final PaymentBill bill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.payments_outlined, size: 20, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Fmt.monthYear(bill.paymentMonth), style: theme.textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  bill.paymentDate != null ? 'Paid ${Fmt.dateMedium(bill.paymentDate!)}' : 'Not yet paid',
                  style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Fmt.money(bill.netAmount, bill.currency),
                style: GoogleFontsSora.size18.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 5),
              PaymentStatusChip(status: bill.status),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.gray),
        ],
      ),
    );
  }
}