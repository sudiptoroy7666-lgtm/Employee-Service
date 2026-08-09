import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/states.dart';
import '../providers/attendance_providers.dart';

class AttendanceDetailScreen extends ConsumerWidget {
  const AttendanceDetailScreen({super.key, required this.recordId});
  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recordAsync = ref.watch(attendanceRecordProvider(recordId));

    return AppScaffold(
      title: 'Attendance Detail',
      body: recordAsync.when(
        loading: () => ListView(padding: const EdgeInsets.all(16), children: const [LoadingSkeleton(blocks: 2)]),
        error: (e, _) => ErrorStateWidget(error: e, onRetry: () => ref.invalidate(attendanceRecordProvider(recordId))),
        data: (record) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Reveal(
                child: AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(Fmt.dateFull(record.date), style: theme.textTheme.headlineSmall),
                                const SizedBox(height: 4),
                                Text('Attendance record', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          AttendanceStatusChip(status: record.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: const Duration(milliseconds: 80),
                child: AppCard(
                  child: Column(
                    children: [
                      InfoRow(label: 'Check-in time', value: record.checkInTime != null ? Fmt.time(record.checkInTime!) : '—'),
                      const Divider(height: 18),
                      InfoRow(label: 'Check-out time', value: record.checkOutTime != null ? Fmt.time(record.checkOutTime!) : '—'),
                      const Divider(height: 18),
                      InfoRow(
                        label: 'Total working hours',
                        value: record.completed ? Fmt.duration(record.totalWorkingMinutes) : '—',
                        valueColor: AppColors.primary,
                      ),
                      if (record.lateMinutes > 0) ...[
                        const Divider(height: 18),
                        InfoRow(label: 'Late by', value: Fmt.duration(record.lateMinutes), valueColor: AppColors.warning),
                      ],
                      if (record.overtimeMinutes > 0) ...[
                        const Divider(height: 18),
                        InfoRow(label: 'Overtime', value: Fmt.duration(record.overtimeMinutes), valueColor: AppColors.success),
                      ],
                      if (record.breakMinutes != null) ...[
                        const Divider(height: 18),
                        InfoRow(label: 'Break', value: Fmt.duration(record.breakMinutes!)),
                      ],
                    ],
                  ),
                ),
              ),
              if (record.notes != null && record.notes!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Reveal(
                  delay: const Duration(milliseconds: 140),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.sticky_note_2_outlined, size: 18, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Note', style: theme.textTheme.titleSmall),
                              const SizedBox(height: 3),
                              Text(record.notes!, style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
