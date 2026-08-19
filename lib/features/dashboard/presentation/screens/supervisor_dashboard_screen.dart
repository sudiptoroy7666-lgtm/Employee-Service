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
import '../providers/dashboard_providers.dart';
import '../widgets/stats_card.dart';

class SupervisorDashboardScreen extends ConsumerWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(authControllerProvider).valueOrNull;
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final teamStatsAsync = ref.watch(teamStatsProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teamStatsProvider);
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(visitsProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.navy,
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
                                  employee?.name ?? 'Supervisor',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sales Manager • Team Overview',
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
                    childAspectRatio: 0.9,
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

                  const SectionHeader(title: 'Team Summary'),
                  const SizedBox(height: 8),
                  teamStatsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => AppCard(
                      child: ErrorStateWidget(
                        error: e,
                        compact: true,
                        onRetry: () => ref.invalidate(teamStatsProvider),
                      ),
                    ),
                    data: (team) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        StatsCard(
                          label: 'Team Members',
                          value: '${team.totalTeamMembers}',
                          icon: Icons.group,
                          tint: AppColors.primary,
                        ),
                        StatsCard(
                          label: 'Active in Field',
                          value: '${team.activeInField}',
                          icon: Icons.directions_walk,
                          tint: AppColors.success,
                        ),
                        StatsCard(
                          label: 'Visits Today',
                          value: '${team.totalVisitsToday}',
                          icon: Icons.add_location,
                          tint: AppColors.warning,
                        ),
                        StatsCard(
                          label: 'Revenue Today',
                          value: '৳${(team.totalRevenueToday / 1000).toStringAsFixed(1)}K',
                          icon: Icons.trending_up,
                          tint: AppColors.navy,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  teamStatsAsync.maybeWhen(
                    data: (team) {
                      final totalPending = team.pendingVisitApprovals + team.pendingLeaveApprovals;
                      if (totalPending == 0) return const SizedBox.shrink();

                      return AppCard(
                        onTap: () {},
                        color: AppColors.warningBg,
                        child: Row(
                          children: [
                            const Icon(Icons.pending_actions, color: AppColors.warning, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pending Approvals',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${team.pendingVisitApprovals} visit approvals • ${team.pendingLeaveApprovals} leave requests',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$totalPending',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  const SectionHeader(title: 'My Performance'),
                  const SizedBox(height: 8),
                  statsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (stats) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        StatsCard(
                          label: 'My Visits Today',
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
