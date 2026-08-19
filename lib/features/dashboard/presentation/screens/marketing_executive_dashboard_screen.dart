import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/states.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../visits/presentation/providers/visit_providers.dart';
import '../../../home/presentation/widgets/checkin_hero_card.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/stats_card.dart';

class MarketingExecutiveDashboardScreen extends ConsumerWidget {
  const MarketingExecutiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(authControllerProvider).valueOrNull;
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final dayState = ref.watch(dayManagementProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final visitsAsync = ref.watch(visitsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(visitsProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${Fmt.greeting(now)},',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  employee?.name ?? 'Marketing Executive',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  employee?.designation ?? 'Field Marketing',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => context.push('/profile'),
                            child: UserAvatar(name: employee?.name ?? '?', size: 44, light: true),
                          ),
                        ],
                      ),
                       const SizedBox(height: 16),
                       _DayStatusCard(dayState: dayState),
                       const SizedBox(height: 12),
                       // ---- Office Check-In / Check-Out ----
                       const Reveal(child: CheckInHeroCard()),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.7,
                    children: [
                      QuickActionCard(
                        label: 'New Visit',
                        icon: Icons.add_location,
                        tint: AppColors.primary,
                        onTap: () => context.push('/visits/new'),
                      ),
                      QuickActionCard(
                        label: 'New Order',
                        icon: Icons.shopping_cart,
                        tint: AppColors.success,
                        onTap: () => context.push('/orders/new'),
                      ),
                      QuickActionCard(
                        label: 'Collection',
                        icon: Icons.attach_money,
                        tint: AppColors.warning,
                        onTap: () => context.push('/collections'),
                      ),
                      QuickActionCard(
                        label: 'Market Info',
                        icon: Icons.campaign,
                        tint: AppColors.navy,
                        onTap: () => context.push('/market-updates/new'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SectionHeader(title: "Today's Performance"),
                  const SizedBox(height: 8),
                  statsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => AppCard(
                      child: ErrorStateWidget(
                        error: e,
                        compact: true,
                        onRetry: () => ref.invalidate(dashboardStatsProvider),
                      ),
                    ),
                    data: (stats) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        StatsCard(
                          label: 'Visits Today',
                          value: '${stats.visitsToday}',
                          icon: Icons.add_location,
                          tint: AppColors.primary,
                        ),
                        StatsCard(
                          label: 'Orders Booked',
                          value: '${stats.totalOrders}',
                          icon: Icons.receipt_long,
                          tint: AppColors.success,
                        ),
                        StatsCard(
                          label: 'Collections',
                          value: '৳${(stats.totalCollection / 1000).toStringAsFixed(1)}K',
                          icon: Icons.attach_money,
                          tint: AppColors.warning,
                        ),
                        StatsCard(
                          label: 'New Leads',
                          value: '${stats.leadsToday}',
                          icon: Icons.person_add,
                          tint: AppColors.navy,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SectionHeader(
                    title: 'My Visits Today',
                    actionLabel: 'View All',
                    onAction: () => context.push('/visits'),
                  ),
                  const SizedBox(height: 8),
                  visitsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => AppCard(
                      child: ErrorStateWidget(
                        error: e,
                        compact: true,
                        onRetry: () => ref.invalidate(visitsProvider),
                      ),
                    ),
                    data: (visits) {
                      if (visits.isEmpty) {
                        return AppCard(
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Icon(Icons.event_available, size: 40, color: AppColors.gray),
                                  SizedBox(height: 12),
                                  Text('No visits scheduled for today'),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tap "New Visit" to create one',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: visits.take(3).map((visit) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            onTap: () => context.push('/visits/detail/${visit.id}'),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.infoBg,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(Icons.add_location, size: 20, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        visit.clientName,
                                        style: Theme.of(context).textTheme.titleSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${visit.visitType.label} • ${Fmt.time(visit.scheduledTime)}',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _VisitStatusBadge(status: visit.status.name),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right, size: 18, color: AppColors.gray),
                              ],
                            ),
                          ),
                        )).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  statsAsync.maybeWhen(
                    data: (stats) {
                      if (stats.leaveQuota == 0) return const SizedBox.shrink();
                      return AppCard(
                        onTap: () => context.push('/leave/new'),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(Icons.beach_access, size: 20, color: AppColors.success),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Leave Balance', style: Theme.of(context).textTheme.titleSmall),
                                  Text(
                                    '${stats.leaveRemaining} days remaining',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18, color: AppColors.gray),
                          ],
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayStatusCard extends StatelessWidget {
  final DayState dayState;

  const _DayStatusCard({required this.dayState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.raised,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: dayState.isDayStarted ? AppColors.successBg : AppColors.grayBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              dayState.isDayStarted ? Icons.play_circle : Icons.pause_circle,
              color: dayState.isDayStarted ? AppColors.success : AppColors.gray,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayState.isDayStarted ? 'Day Started' : 'Day Not Started',
                  style: theme.textTheme.titleMedium,
                ),
                if (dayState.isDayStarted && dayState.startTime != null)
                  Text(
                    'Started at ${Fmt.time(dayState.startTime!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Text(
                    'Tap to start your field day',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/visits/day-management'),
            style: TextButton.styleFrom(
              backgroundColor: dayState.isDayStarted ? AppColors.dangerBg : AppColors.successBg,
              foregroundColor: dayState.isDayStarted ? AppColors.danger : AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              dayState.isDayStarted ? 'End Day' : 'Start Day',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitStatusBadge extends StatelessWidget {
  final String status;

  const _VisitStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status.toLowerCase()) {
      'pending' => (AppColors.warning, AppColors.warningBg, 'Pending'),
      'checkedin' => (AppColors.primary, AppColors.infoBg, 'Active'),
      'completed' => (AppColors.success, AppColors.successBg, 'Done'),
      'cancelled' => (AppColors.danger, AppColors.dangerBg, 'Cancelled'),
      _ => (AppColors.gray, AppColors.grayBg, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
