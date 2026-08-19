import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/attendance.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/states.dart';
import '../providers/attendance_providers.dart';
import '../widgets/attendance_calendar.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthAttendanceAsync = ref.watch(attendanceMonthProvider(_month));

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: monthAttendanceAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [LoadingSkeleton(blocks: 4)],
        ),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.invalidate(attendanceMonthProvider(_month)),
        ),
        data: (monthAttendance) {
          final summary = monthAttendance.summary;
          final records = monthAttendance.records;
          final calendarStatuses = monthAttendance.calendar;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              MonthSelector(
                month: _month,
                minMonth: DateTime(2026, 1),
                maxMonth: DateTime.now(),
                onChanged: (m) => setState(() => _month = DateTime(m.year, m.month)),
              ),
              const SizedBox(height: 16),

              Reveal(
                child: _SummaryGrid(summary: summary),
              ),
              const SizedBox(height: 16),

              Reveal(
                delay: const Duration(milliseconds: 70),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Fmt.monthYear(_month), style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      AttendanceCalendar(
                        month: _month,
                        statuses: calendarStatuses,
                        onDayTap: (date) {
                          final rec = records.where((r) => DateUtils.dateOnly(r.date) == date).firstOrNull;
                          if (rec != null) context.push('/attendance/detail/${rec.id}');
                        },
                      ),
                      const SizedBox(height: 12),
                      const CalendarLegend(),
                    ],
                  ),
                ),
              ),

              const SectionHeader(title: 'Attendance History'),

              if (records.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.event_busy_outlined,
                  title: 'No attendance records',
                  message: 'There are no attendance records for this month yet.',
                )
              else
                ...List.generate(records.length, (i) {
                  final record = records[i];
                  return Reveal(
                    delay: Duration(milliseconds: 120 + i * 45),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AttendanceRecordCard(record: record),
                    ),
                  );
                }),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});
  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = constraints.maxWidth > 620 ? 4 : 2;
        return GridView.count(
          crossAxisCount: cross,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: cross == 4 ? 2.6 : 2.0,
          children: [
            _SummaryTile(label: 'Working Days', value: '${summary.workingDays}', color: AppColors.primary, icon: Icons.calendar_month_outlined),
            _SummaryTile(label: 'Present', value: '${summary.present}', color: AppColors.success, icon: Icons.check_circle_outline),
            _SummaryTile(label: 'Late', value: '${summary.late}', color: AppColors.warning, icon: Icons.schedule_outlined),
            _SummaryTile(label: 'Absent', value: '${summary.absent}', color: AppColors.danger, icon: Icons.cancel_outlined),
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value, required this.color, required this.icon});
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: GoogleFontsSora.size22.copyWith(fontSize: 20, color: color)),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRecordCard extends StatelessWidget {
  final AttendanceRecord record;

  const _AttendanceRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => context.push('/attendance/detail/${record.id}'),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${record.date.day}', style: GoogleFontsSora.size18.copyWith(fontSize: 16, color: AppColors.primaryDark)),
                    Text(
                      Fmt.dateShort(record.date).split(' ').last.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primary, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Fmt.dateFull(record.date), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      record.checkInTime != null && record.checkOutTime != null
                          ? 'Worked ${Fmt.duration(record.totalWorkingMinutes)}'
                          : 'No hours recorded',
                      style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: record.status.label),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.gray),
            ],
          ),
          if (record.checkInTime != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: AppColors.grayBg.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: _mini('Check In', Fmt.time(record.checkInTime!), theme),
                  ),
                  Expanded(
                    child: _mini('Check Out', record.checkOutTime != null ? Fmt.time(record.checkOutTime!) : '—', theme),
                  ),
                  Expanded(
                    child: _mini('Working Time', record.checkInTime != null && record.checkOutTime != null ? Fmt.duration(record.totalWorkingMinutes) : '—', theme),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mini(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: AppColors.gray)),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleSmall?.copyWith(fontSize: 12.5)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status.toLowerCase()) {
      'present' => (AppColors.success, AppColors.successBg, 'Present'),
      'late' => (AppColors.warning, AppColors.warningBg, 'Late'),
      'absent' => (AppColors.danger, AppColors.dangerBg, 'Absent'),
      _ => (AppColors.gray, AppColors.grayBg, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
