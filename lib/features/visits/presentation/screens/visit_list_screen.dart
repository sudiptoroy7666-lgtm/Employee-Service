import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/states.dart';
import '../../domain/models/visit_status.dart';
import '../providers/visit_providers.dart';

class VisitListScreen extends ConsumerWidget {
  const VisitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(visitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Visits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/visits/new'),
        icon: const Icon(Icons.add_location),
        label: const Text('New Visit'),
      ),
      body: visitsAsync.when(
        loading: () => ListView(padding: const EdgeInsets.all(16), children: const [LoadingSkeleton(blocks: 4)]),
        error: (e, _) => ErrorStateWidget(error: e, onRetry: () => ref.invalidate(visitsProvider)),
        data: (visits) {
          if (visits.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.add_location_outlined,
              title: 'No visits today',
              message: 'Start your day by creating a new visit.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(visitsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return AppCard(
                  onTap: () => context.push('/visits/detail/${visit.id}'),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(11)),
                            child: const Icon(Icons.add_location, size: 20, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(visit.clientName, style: Theme.of(context).textTheme.titleSmall),
                                Text('${visit.clientType.label} • ${visit.visitType.label}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          _StatusChip(status: visit.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.gray),
                          const SizedBox(width: 4),
                          Text(Fmt.time(visit.scheduledTime), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                          const Spacer(),
                          if (visit.checkInTime != null) ...[
                            const Icon(Icons.login, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(Fmt.time(visit.checkInTime!), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.success)),
                          ],
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

class _StatusChip extends StatelessWidget {
  final VisitStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      VisitStatus.pending => (AppColors.warning, AppColors.warningBg),
      VisitStatus.checkedIn => (AppColors.primary, AppColors.infoBg),
      VisitStatus.completed => (AppColors.success, AppColors.successBg),
      VisitStatus.cancelled => (AppColors.danger, AppColors.dangerBg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
