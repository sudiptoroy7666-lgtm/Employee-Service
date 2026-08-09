import 'package:flutter/material.dart';

import '../../../../core/models/attendance.dart';
import '../../../../core/theme/app_theme.dart';

class AttendanceCalendar extends StatelessWidget {
  const AttendanceCalendar({super.key, required this.month, required this.statuses, this.onDayTap});

  final DateTime month;
  final Map<DateTime, AttendanceStatus> statuses;
  final ValueChanged<DateTime>? onDayTap;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Color _tint(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return AppColors.success;
      case AttendanceStatus.late:
        return AppColors.warning;
      case AttendanceStatus.absent:
        return AppColors.danger;
      case AttendanceStatus.holiday:
        return AppColors.primary;
      case AttendanceStatus.weekend:
        return AppColors.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final first = DateTime(month.year, month.month, 1);
    final leading = (first.weekday - 1) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final cells = <Widget>[
      for (var i = 0; i < leading; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _dayCell(DateTime(month.year, month.month, day), today, theme),
    ];

    return Column(
      children: [
        Row(
          children: [
            for (final d in _weekdays)
              Expanded(
                child: Center(
                  child: Text(d, style: theme.textTheme.labelSmall?.copyWith(color: AppColors.gray, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.92,
          children: cells,
        ),
      ],
    );
  }

  Widget _dayCell(DateTime date, DateTime today, ThemeData theme) {
    final status = statuses[date];
    final isToday = date == today;
    final isFuture = date.isAfter(today);
    final color = status == null ? null : _tint(status);
    final tappable = onDayTap != null &&
        status != null &&
        (status == AttendanceStatus.present || status == AttendanceStatus.late || status == AttendanceStatus.absent);

    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: tappable ? () => onDayTap!(date) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: color == null ? Colors.transparent : color.withValues(alpha: status == AttendanceStatus.weekend ? 0 : 0.10),
              borderRadius: BorderRadius.circular(10),
              border: isToday ? Border.all(color: AppColors.primary, width: 1.6) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                    color: isFuture
                        ? AppColors.gray.withValues(alpha: 0.5)
                        : status == AttendanceStatus.weekend
                        ? AppColors.gray
                        : color ?? theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color == null || isFuture || status == AttendanceStatus.weekend
                        ? Colors.transparent
                        : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  static const _legendItems = [
    ('Present', AppColors.success),
    ('Late', AppColors.warning),
    ('Absent', AppColors.danger),
    ('Holiday', AppColors.primary),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final (label, color) in _legendItems)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
      ],
    );
  }
}
