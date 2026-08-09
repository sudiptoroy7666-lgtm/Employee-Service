import 'package:flutter/material.dart';

import '../../../../core/models/leave.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/chips.dart';

class LeaveRequestCard extends StatelessWidget {
  const LeaveRequestCard({super.key, required this.request, required this.onTap});
  final LeaveRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               Container(
                 width: 38,
                 height: 38,
                 decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(11)),
                 child: const Icon(Icons.beach_access, size: 18, color: AppColors.primary),
               ),
               const SizedBox(width: 10),
               Expanded(child: Text(request.leaveType.label, style: theme.textTheme.titleMedium)),
               LeaveStatusChip(status: request.status),
             ],
           ),
           if (request.isLocalOnly) ...[
             const SizedBox(height: 10),
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(
                 color: AppColors.warningBg,
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Row(
                 children: [
                   const Icon(Icons.cloud_off, size: 16, color: AppColors.warning),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       'Awaiting server sync',
                       style: theme.textTheme.labelSmall?.copyWith(
                         color: const Color(0xFF93520A),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ],
           const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(color: AppColors.grayBg.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.date_range_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: Text(Fmt.dateRange(request.startDate, request.endDate), style: theme.textTheme.titleSmall)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    '${request.numberOfDays} ${request.numberOfDays == 1 ? 'Day' : 'Days'}',
                    style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Submitted ${Fmt.relative(request.submittedAt)}',
            style: theme.textTheme.labelMedium?.copyWith(color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}