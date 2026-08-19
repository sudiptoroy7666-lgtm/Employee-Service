import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/activity.dart';
import '../../../../core/models/attendance.dart';
import '../../../../core/models/check_in_out.dart';
import '../../../../core/models/leave.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/states.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../leave/presentation/providers/leave_providers.dart';
import '../providers/home_providers.dart';

// ------------------------------------------------- Today's Summary grid

class TodaySummaryGrid extends ConsumerWidget {
  const TodaySummaryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final record = ref.watch(todayAttendanceProvider).valueOrNull;
    final leaveBalances = ref.watch(leaveBalanceProvider).valueOrNull;
    final pending = ref
        .watch(leaveRequestsProvider)
        .valueOrNull
        ?.where((r) => r.status == LeaveStatus.pending)
        .length ??
        0;

    final checkedIn = record?.checkInTime != null;
    final late = checkedIn &&
        (record!.checkInTime!.hour * 60 + record.checkInTime!.minute) > 9 * 60 + 15;
    final annual = leaveBalances?.where((b) => b.type == LeaveType.annual).firstOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = constraints.maxWidth > 640 ? 4 : 2;
        return GridView.count(
          crossAxisCount: cross,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          // StatCard needs ~58px (12pad×2 + 34icon). 2.4 gives cells ≥63px at all
          // 4‑column widths → safe from overflow, balanced portrait proportions.
          childAspectRatio: cross == 4 ? 2.4 : 1.5,
          children: [
            StatCard(
              label: 'Attendance Status',
              value: !checkedIn ? 'Not checked in' : late ? 'Late' : 'Present',
              icon: late ? Icons.schedule_outlined : Icons.check_circle_outline,
              tint: !checkedIn ? AppColors.gray : late ? AppColors.warning : AppColors.success,
              valueColor: !checkedIn ? AppColors.gray : late ? AppColors.warning : AppColors.success,
            ),
            _LiveWorkingHoursCard(record: record, now: now),
            StatCard(
              label: 'Leave Balance',
              value: annual == null ? '—' : '${annual.remainingDays} Days',
              icon: Icons.beach_access,
              tint: AppColors.primary,
            ),
            StatCard(
              label: 'Pending Requests',
              value: '$pending Pending',
              icon: Icons.hourglass_top_outlined,
              tint: pending > 0 ? AppColors.warning : AppColors.gray,
              valueColor: pending > 0 ? AppColors.warning : null,
            ),
          ],
        );
      },
    );
  }
}

class _LiveWorkingHoursCard extends ConsumerWidget {
  const _LiveWorkingHoursCard({required this.record, required this.now});
  final CheckInOutRecord? record;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveNow = ref.watch(clockProvider).valueOrNull ?? now;
    final minutes = record?.workingMinutes(liveNow) ?? 0;
    return StatCard(
      label: 'Working Hours',
      value: minutes > 0 ? Fmt.duration(minutes) : '00h 00m',
      icon: Icons.timer_outlined,
      tint: AppColors.primary,
    );
  }
}

// --------------------------------------------- Monthly attendance summary

class MonthlySummaryCard extends ConsumerWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final month = DateTime(DateTime.now().year, DateTime.now().month);
    final monthAsync = ref.watch(attendanceMonthProvider(month));

    return monthAsync.when(
      loading: () => const Shimmer(
        child: SizedBox(
          height: 120,
          child: SkeletonLine(height: 120, radius: 16),
        ),
      ),
      error: (e, _) => AppCard(child: ErrorStateWidget(error: e, compact: true, onRetry: () => ref.invalidate(attendanceMonthProvider))),
      data: (data) {
        final s = data.summary;
        final total = (s.present + s.late + s.absent).clamp(1, 999999);
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Fmt.monthYear(data.month), style: theme.textTheme.titleMedium),
              const SizedBox(height: 14),
              Row(
                children: [
                  _monthStat('Working Days', '${s.workingDays}', AppColors.primary, theme),
                  _monthStat('Present', '${s.present}', AppColors.success, theme),
                  _monthStat('Late', '${s.late}', AppColors.warning, theme),
                  _monthStat('Absent', '${s.absent}', AppColors.danger, theme),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      Expanded(flex: s.present, child: Container(color: AppColors.success)),
                      if (s.late > 0) Expanded(flex: s.late, child: Container(color: AppColors.warning)),
                      if (s.absent > 0) Expanded(flex: s.absent, child: Container(color: AppColors.danger)),
                      if (s.present + s.late + s.absent == 0) Expanded(child: Container(color: AppColors.grayBg)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$total day${total == 1 ? '' : 's'} recorded so far this month',
                style: theme.textTheme.labelSmall?.copyWith(color: AppColors.gray),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _monthStat(String label, String value, Color color, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFontsSora.size22.copyWith(fontSize: 20, color: color)),
          const SizedBox(height: 3),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------- Weekly strip

class WeeklyAttendanceStrip extends ConsumerWidget {
  const WeeklyAttendanceStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final month = DateTime(DateTime.now().year, DateTime.now().month);
    final monthAsync = ref.watch(attendanceMonthProvider(month));
    final today = DateUtils.dateOnly(DateTime.now());

    // Monday of the current week
    final monday = today.subtract(Duration(days: today.weekday - 1));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week', style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          monthAsync.maybeWhen(
            data: (data) => Row(
              children: List.generate(7, (i) {
                final date = monday.add(Duration(days: i));
                final status = data.calendar[date];
                final isToday = date == today;
                final (letter, color) = switch (status) {
                  AttendanceStatus.present => ('P', AppColors.success),
                  AttendanceStatus.late => ('L', AppColors.warning),
                  AttendanceStatus.absent => ('A', AppColors.danger),
                  AttendanceStatus.holiday => ('H', AppColors.primary),
                  _ => ('–', AppColors.gray),
                };
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        labels[i],
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isToday ? AppColors.primary : AppColors.gray,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 7),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: status == null || status == AttendanceStatus.weekend ? 0.0 : 0.13),
                          border: isToday ? Border.all(color: AppColors.primary, width: 1.8) : null,
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: status == null || status == AttendanceStatus.weekend ? AppColors.gray : color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            orElse: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------- Leave balance

class LeaveBalanceCard extends ConsumerWidget {
  const LeaveBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final balancesAsync = ref.watch(leaveBalanceProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Leave Balance', style: theme.textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/leave'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('View Leave', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          balancesAsync.when(
            loading: () => const Shimmer(
              child: Column(children: [SkeletonLine(height: 34), SizedBox(height: 10), SkeletonLine(height: 34)]),
            ),
            error: (_, __) => Text('Unavailable', style: theme.textTheme.bodySmall),
            data: (balances) => Column(
              children: [
                for (final b in balances) ...[
                  Row(
                    children: [
                      Text(b.type.label, style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Text(
                        '${b.remainingDays} days remaining',
                        style: theme.textTheme.titleSmall?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: b.usedFraction,
                      minHeight: 7,
                      backgroundColor: AppColors.grayBg,
                      valueColor: AlwaysStoppedAnimation(
                        b.type == LeaveType.annual ? AppColors.primary : b.type == LeaveType.sick ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------- Quick actions

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = constraints.maxWidth > 640 ? 4 : 2;
        return GridView.count(
          crossAxisCount: cross,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: cross == 4 ? 2.2 : 1.6,
          children: [
            QuickActionCard(label: 'View Attendance', icon: Icons.event_available, tint: AppColors.primary, onTap: () => context.go('/attendance')),
            QuickActionCard(label: 'Request Leave', icon: Icons.beach_access, tint: AppColors.warning, onTap: () => context.push('/leave/new')),
            QuickActionCard(label: 'View Payments', icon: Icons.payments_outlined, tint: AppColors.success, onTap: () => context.go('/payments')),
            QuickActionCard(label: 'View Statement', icon: Icons.summarize_outlined, tint: AppColors.navy, onTap: () => context.push('/statement')),
          ],
        );
      },
    );
  }
}

// ------------------------------------------------------- Recent activity

class RecentActivityList extends ConsumerWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return activitiesAsync.when(
      loading: () => const Shimmer(
        child: Column(children: [
          SkeletonLine(height: 52),
          SizedBox(height: 10),
          SkeletonLine(height: 52),
          SizedBox(height: 10),
          SkeletonLine(height: 52),
        ]),
      ),
      error: (e, _) => AppCard(child: ErrorStateWidget(error: e, compact: true, onRetry: () => ref.invalidate(recentActivitiesProvider))),
      data: (activities) {
        if (activities.isEmpty) {
          return const AppCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: Text('No recent activity')),
            ),
          );
        }
        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: List.generate(activities.length, (i) {
              final a = activities[i];
              final (icon, color) = _meta(a.type);
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(11)),
                          child: Icon(icon, size: 18, color: color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title, style: theme.textTheme.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                a.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Fmt.relative(a.occurredAt),
                          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.gray),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  (IconData, Color) _meta(ActivityType type) {
    switch (type) {
      case ActivityType.checkIn:
        return (Icons.login_rounded, AppColors.primary);
      case ActivityType.checkOut:
        return (Icons.logout_rounded, AppColors.navy);
      case ActivityType.leaveSubmitted:
        return (Icons.send_outlined, AppColors.warning);
      case ActivityType.leaveApproved:
        return (Icons.check_circle_outline, AppColors.success);
      case ActivityType.payment:
        return (Icons.payments_outlined, AppColors.success);
    }
  }
}