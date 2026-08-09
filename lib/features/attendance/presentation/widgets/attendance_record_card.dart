import 'package:flutter/material.dart';

import '../../../../core/models/attendance.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/chips.dart';

class AttendanceRecordCard extends StatelessWidget {
  const AttendanceRecordCard({super.key, required this.record, required this.onTap});
  final AttendanceRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
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
                      record.completed
                          ? 'Worked ${Fmt.duration(record.totalWorkingMinutes)}'
                          : 'No hours recorded',
                      style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              AttendanceStatusChip(status: record.status),
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
                    child: _mini('Working Time', record.completed ? Fmt.duration(record.totalWorkingMinutes) : '—', theme),
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