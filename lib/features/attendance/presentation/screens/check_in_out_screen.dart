import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/check_in_out.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../../core/widgets/states.dart';
import '../providers/attendance_providers.dart';

class CheckInOutScreen extends ConsumerWidget {
  const CheckInOutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayAsync = ref.watch(todayAttendanceProvider);
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();

    return AppScaffold(
      title: 'Check In / Check Out',
      body: todayAsync.when(
        loading: () => ListView(padding: const EdgeInsets.all(16), children: const [LoadingSkeleton(blocks: 2)]),
        error: (e, _) => ErrorStateWidget(error: e),
        data: (record) {
          final effectiveCheckIn = record.checkInTime;
          final effectiveCheckOut = record.checkOutTime;

          final effectiveRecord = CheckInOutRecord(
            id: record.id,
            employeeId: record.employeeId,
            date: record.date,
            checkInTime: effectiveCheckIn,
            checkOutTime: effectiveCheckOut,
            breakStart: record.breakStart,
            breakEnd: record.breakEnd,
          );

          final status = effectiveRecord.status;
          final workingMinutes = effectiveRecord.workingMinutes(now);
          final progress = math.min(1.0, workingMinutes / (9 * 60));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Reveal(
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(Fmt.dateFull(effectiveRecord.date), style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        Fmt.time(now),
                        style: GoogleFontsSora.size22.copyWith(fontSize: 40, letterSpacing: 1),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: status == WorkdayStatus.notStarted ? 0 : progress,
                              strokeWidth: 11,
                              strokeCap: StrokeCap.round,
                              backgroundColor: AppColors.grayBg,
                              valueColor: AlwaysStoppedAnimation(
                                status == WorkdayStatus.completed ? AppColors.success : AppColors.primary,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    status == WorkdayStatus.notStarted
                                        ? '—'
                                        : Fmt.duration(workingMinutes),
                                    style: GoogleFontsSora.size22.copyWith(fontSize: 28),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    status == WorkdayStatus.working ? 'Working now' : status == WorkdayStatus.completed ? 'Total today' : 'Ready when you are',
                                    style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      switch (status) {
                        WorkdayStatus.notStarted => const StatusChip(
                          label: 'Ready to start your workday',
                          color: AppColors.textSecondary,
                          background: AppColors.grayBg,
                          dot: false,
                          icon: Icons.wb_sunny_outlined,
                        ),
                        WorkdayStatus.working => const StatusChip(
                          label: 'Currently Working',
                          color: AppColors.success,
                          background: AppColors.successBg,
                          dot: false,
                          icon: Icons.play_circle_outline,
                        ),
                        WorkdayStatus.completed => const StatusChip(
                          label: 'Workday Completed',
                          color: AppColors.success,
                          background: AppColors.successBg,
                          dot: false,
                          icon: Icons.check_circle_outline,
                        ),
                      },
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: const Duration(milliseconds: 80),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Timeline", style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      ActivityTimeline(
                        events: [
                          if (effectiveRecord.checkInTime != null)
                            TimelineEvent(time: effectiveRecord.checkInTime!, label: 'Checked In', icon: Icons.login_rounded, color: AppColors.primary),
                          if (effectiveRecord.breakStart != null)
                            TimelineEvent(time: effectiveRecord.breakStart!, label: 'Break Started', icon: Icons.coffee_outlined, color: AppColors.warning),
                          if (effectiveRecord.breakEnd != null)
                            TimelineEvent(time: effectiveRecord.breakEnd!, label: 'Break Ended', icon: Icons.play_arrow_rounded, color: AppColors.success),
                          if (effectiveRecord.checkOutTime != null)
                            TimelineEvent(time: record.checkOutTime!, label: 'Checked Out', icon: Icons.logout_rounded, color: AppColors.navy),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: const Duration(milliseconds: 140),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Scheduled shift 09:00 AM – 06:00 PM · Grace period 15 minutes',
                          style: theme.textTheme.labelMedium?.copyWith(color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              if (status == WorkdayStatus.notStarted)
                PrimaryButton(
                  label: 'Check In',
                  icon: Icons.fingerprint,
                  loading: todayAsync.isLoading,
                  onPressed: () => _checkIn(context, ref),
                )
              else if (status == WorkdayStatus.working)
                PrimaryButton(
                  label: 'Check Out',
                  icon: Icons.logout_rounded,
                  loading: todayAsync.isLoading,
                  onPressed: () => _confirmCheckOut(context, ref, record, now),
                )
              else
                SecondaryButton(
                  label: 'View Attendance History',
                  icon: Icons.history,
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(todayAttendanceProvider.notifier).checkIn();
      if (context.mounted) AppSnack.success(context, 'Checked in — have a great day!');
    } on AppFailure catch (e) {
      if (context.mounted) AppSnack.error(context, e.message);
    }
  }

  Future<void> _confirmCheckOut(BuildContext context, WidgetRef ref, CheckInOutRecord record, DateTime now) async {
    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Check Out',
      confirmLabel: 'Check Out',
      confirmIcon: Icons.logout_rounded,
      body: Column(
        children: [
          InfoRow(label: 'Current time', value: Fmt.time(now)),
          const Divider(height: 18),
          InfoRow(label: 'Checked in at', value: Fmt.time(record.checkInTime!)),
          const Divider(height: 18),
          InfoRow(
            label: 'Working duration',
            value: Fmt.duration(record.workingMinutes(now)),
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'You are about to end your workday for today.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(todayAttendanceProvider.notifier).checkOut();
      if (context.mounted) AppSnack.success(context, 'Checked out — workday completed. Well done!');
    } on AppFailure catch (e) {
      if (context.mounted) AppSnack.error(context, e.message);
    }
  }
}