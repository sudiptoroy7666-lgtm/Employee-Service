import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/states.dart';
import '../providers/complaint_providers.dart';
import '../../domain/models/complaint.dart';

class ComplaintListScreen extends ConsumerWidget {
  const ComplaintListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(complaintsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Complaints')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/complaints/new'),
        icon: const Icon(Icons.report_problem),
        label: const Text('New Complaint'),
      ),
      body: complaintsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [LoadingSkeleton(blocks: 4)],
        ),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.invalidate(complaintsProvider),
        ),
        data: (complaints) {
          if (complaints.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.report_problem_outlined,
              title: 'No complaints',
              message: 'All good! No complaints have been submitted.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(complaintsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.report_problem, size: 20, color: AppColors.warning),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(complaint.subject, style: Theme.of(context).textTheme.titleSmall),
                                Text(
                                  complaint.clientName,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _PriorityChip(priority: complaint.priority),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        complaint.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            Fmt.dateMedium(complaint.submittedDate),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.gray,
                            ),
                          ),
                          const Spacer(),
                          _StatusChip(status: complaint.status),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final ComplaintPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (priority) {
      ComplaintPriority.low => (AppColors.gray, AppColors.grayBg),
      ComplaintPriority.medium => (AppColors.warning, AppColors.warningBg),
      ComplaintPriority.high => (AppColors.danger, AppColors.dangerBg),
      ComplaintPriority.urgent => (AppColors.danger, AppColors.dangerBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        priority.label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ComplaintStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      ComplaintStatus.open => (AppColors.warning, AppColors.warningBg),
      ComplaintStatus.inProgress => (AppColors.primary, AppColors.infoBg),
      ComplaintStatus.resolved => (AppColors.success, AppColors.successBg),
      ComplaintStatus.closed => (AppColors.gray, AppColors.grayBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
