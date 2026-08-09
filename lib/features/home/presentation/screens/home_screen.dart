import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/office_map_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../leave/presentation/providers/leave_providers.dart';
import '../providers/home_providers.dart';
import '../widgets/checkin_hero_card.dart';
import '../widgets/home_sections.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(authControllerProvider).valueOrNull;
   // final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final name = employee?.firstName ?? 'there';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceMonthProvider);
          ref.invalidate(recentActivitiesProvider);
          ref.invalidate(leaveBalanceProvider);
          await Future.wait([
            ref.read(todayAttendanceProvider.notifier).refresh(),
            ref.read(leaveRequestsProvider.notifier).refresh(),
          ]);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Branded header band
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 15),
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
                                  '${Fmt.greeting(DateTime.now())}, $name', // 👈 USE DateTime.now() directly
                                  style: GoogleFontsSora.size22.copyWith(fontSize: 21, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Here's your work summary for today",
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => context.push('/profile'),
                            child: UserAvatar(name: employee?.name ?? '?', size: 40, light: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Reveal(child: CheckInHeroCard()),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ NEW: Office Map
                      Reveal(child: OfficeMapCard()),
                      SizedBox(height: 16),
                      SectionHeader(title: "Today's Summary"),
                      Reveal(delay: Duration(milliseconds: 60), child: TodaySummaryGrid()),
                      SectionHeader(title: 'Monthly Attendance'),
                      Reveal(delay: Duration(milliseconds: 110), child: MonthlySummaryCard()),
                      SizedBox(height: 14),
                      Reveal(delay: Duration(milliseconds: 160), child: WeeklyAttendanceStrip()),
                      SectionHeader(title: 'Leave Balance'),
                      Reveal(delay: Duration(milliseconds: 210), child: LeaveBalanceCard()),
                      SectionHeader(title: 'Quick Actions'),
                      Reveal(delay: Duration(milliseconds: 260), child: QuickActionsGrid()),
                      SectionHeader(title: 'Recent Activity'),
                      Reveal(delay: Duration(milliseconds: 310), child: RecentActivityList()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}