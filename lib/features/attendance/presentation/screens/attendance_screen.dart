import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/states.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/attendance_providers.dart';
import '../widgets/attendance_calendar.dart';
import '../widgets/attendance_record_card.dart';

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
    final monthAsync = ref.watch(attendanceMonthProvider(_month));
    final joining = ref.read(authControllerProvider).valueOrNull?.joiningDate ??
        DateTime(DateTime.now().year, DateTime.now().month);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(attendanceMonthProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MonthSelector(
              month: _month,
              minMonth: DateTime(joining.year, joining.month),
              maxMonth: DateTime.now(),
              onChanged: (m) => setState(() => _month = DateTime(m.year, m.month)),
            ),
            const SizedBox(height: 16),
            monthAsync.when(
              loading: () => const LoadingSkeleton(blocks: 3),
              error: (e, _) => ErrorStateWidget(error: e, onRetry: () => ref.invalidate(attendanceMonthProvider)),
              data: (data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Reveal(child: _SummaryGrid(summary: data.summary)),
                    const SizedBox(height: 16),
                    Reveal(
                      delay: const Duration(milliseconds: 70),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Fmt.monthYear(data.month), style: theme.textTheme.titleMedium),
                            const SizedBox(height: 12),
                            AttendanceCalendar(
                              month: data.month,
                              statuses: data.calendar,
                              onDayTap: (date) {
                                final rec = data.records.where((r) => DateUtils.dateOnly(r.date) == date).firstOrNull;
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
                    if (data.records.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.event_busy_outlined,
                        title: 'No attendance records',
                        message: 'There are no attendance records for this month yet.',
                      )
                    else
                      ...List.generate(data.records.length, (i) {
                        final record = data.records[i];
                        return Reveal(
                          delay: Duration(milliseconds: 120 + i * 45),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AttendanceRecordCard(
                              record: record,
                              onTap: () => context.push('/attendance/detail/${record.id}'),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {

  const _SummaryGrid({required this.summary});
  final dynamic summary;

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