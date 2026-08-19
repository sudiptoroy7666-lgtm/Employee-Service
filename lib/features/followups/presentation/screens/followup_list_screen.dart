import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/states.dart';
import '../../domain/models/followup.dart';
import '../providers/followup_providers.dart';

class FollowUpListScreen extends ConsumerWidget {
  const FollowUpListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followUpsAsync = ref.watch(followUpsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Follow-Ups')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/followups/new'),
        icon: const Icon(Icons.follow_the_signs),
        label: const Text('New Follow-Up'),
      ),
      body: followUpsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [LoadingSkeleton(blocks: 4)],
        ),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.invalidate(followUpsProvider),
        ),
        data: (followUps) {
          if (followUps.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.follow_the_signs_outlined,
              title: 'No follow-ups yet',
              message: 'Create a follow-up for your leads.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(followUpsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: followUps.length,
              itemBuilder: (context, index) {
                final fu = followUps[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.infoBg,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(Icons.follow_the_signs, size: 20, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fu.leadName ?? 'Lead #${fu.leadId}',
                                    style: Theme.of(context).textTheme.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    Fmt.dateFull(fu.followUpDate),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (fu.outcome != null)
                              _OutcomeChip(outcome: fu.outcome!),
                          ],
                        ),
                        if (fu.notes != null && fu.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            fu.notes!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
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

class _OutcomeChip extends StatelessWidget {
  final FollowUpOutcome outcome;

  const _OutcomeChip({required this.outcome});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (outcome) {
      FollowUpOutcome.interested => (AppColors.success, AppColors.successBg),
      FollowUpOutcome.notInterested => (AppColors.danger, AppColors.dangerBg),
      FollowUpOutcome.followUpAgain => (AppColors.warning, AppColors.warningBg),
      FollowUpOutcome.converted => (AppColors.success, AppColors.successBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        outcome.label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
