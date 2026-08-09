import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/leave.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/states.dart';
import '../providers/leave_providers.dart';

class LeaveDetailScreen extends ConsumerWidget {
  const LeaveDetailScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final requestAsync = ref.watch(leaveDetailProvider(requestId));

    return AppScaffold(
      title: 'Leave Request',
      body: requestAsync.when(
         loading: () => ListView(padding: const EdgeInsets.all(16), children: const [LoadingSkeleton(blocks: 2)]),
        error: (e, _) => ErrorStateWidget(error: e, onRetry: () => ref.invalidate(leaveDetailProvider(requestId))),
        data: (request) {
          final (bannerBg, bannerColor, bannerIcon) = switch (request.status) {
            LeaveStatus.pending => (AppColors.warningBg, const Color(0xFF93520A), Icons.schedule_outlined),
            LeaveStatus.approved => (AppColors.successBg, const Color(0xFF067647), Icons.check_circle_outline),
            LeaveStatus.rejected => (AppColors.dangerBg, const Color(0xFFB42318), Icons.cancel_outlined),
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Reveal(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bannerBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: bannerColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(bannerIcon, color: bannerColor, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.status == LeaveStatus.pending
                                  ? 'Awaiting HR approval'
                                  : request.status == LeaveStatus.approved
                                  ? 'Request approved'
                                  : 'Request rejected',
                              style: theme.textTheme.titleMedium?.copyWith(color: bannerColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Submitted ${Fmt.relative(request.submittedAt)}',
                              style: theme.textTheme.labelMedium?.copyWith(color: bannerColor.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                      LeaveStatusChip(status: request.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: const Duration(milliseconds: 80),
                child: AppCard(
                  child: Column(
                    children: [
                      InfoRow(label: 'Leave type', value: request.leaveType.label),
                      const Divider(height: 18),
                      InfoRow(label: 'Start date', value: Fmt.dateMedium(request.startDate)),
                      const Divider(height: 18),
                      InfoRow(label: 'End date', value: Fmt.dateMedium(request.endDate)),
                      const Divider(height: 18),
                      InfoRow(
                        label: 'Duration',
                        value: '${request.numberOfDays} ${request.numberOfDays == 1 ? 'working day' : 'working days'}',
                        valueColor: AppColors.primary,
                      ),
                      const Divider(height: 18),
                      InfoRow(label: 'Submitted on', value: Fmt.dateMedium(request.submittedAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: const Duration(milliseconds: 140),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(request.reason, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              if (request.reviewerComment != null) ...[
                const SizedBox(height: 14),
                Reveal(
                  delay: const Duration(milliseconds: 200),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.rate_review_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Reviewer Comment', style: theme.textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(12)),
                          child: Text('“${request.reviewerComment}”', style: theme.textTheme.bodyMedium),
                        ),
                        if (request.reviewerName != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '— ${request.reviewerName}'
                                '${request.reviewedAt != null ? ' · ${Fmt.dateMedium(request.reviewedAt!)}' : ''}',
                            style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}