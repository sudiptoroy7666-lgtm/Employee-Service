import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/check_in_out.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';

/// The primary focus of the dashboard — check in / check out, live.
class CheckInHeroCard extends ConsumerWidget {
  const CheckInHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayAsync = ref.watch(todayAttendanceProvider);
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: todayAsync.when(
        loading: () => Container(
          key: const ValueKey('hero-loading'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.raised),
          child: const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
        ),
        error: (e, _) => Container(
          key: const ValueKey('hero-error'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.raised),
          child: Column(
            children: [
              Text("Couldn't load today's attendance", style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: () => ref.read(todayAttendanceProvider.notifier).refresh(),
              ),
            ],
          ),
        ),
        data: (record) {
          final status = record.status;
          return Container(
            key: ValueKey('hero-$status'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.raised),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Today's Attendance", style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      Fmt.dateShort(now),
                      style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                switch (status) {
                  WorkdayStatus.notStarted => _notStarted(context, ref, todayAsync.isLoading, now),
                  WorkdayStatus.working => _working(context, ref, record, now, todayAsync.isLoading),
                  WorkdayStatus.completed => _completed(context, record),
                },
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _notStarted(BuildContext context, WidgetRef ref, bool loading, DateTime now) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(color: AppColors.grayBg, shape: BoxShape.circle),
              child: const Icon(Icons.fingerprint, size: 24, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("You haven't checked in yet.", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(Fmt.dateFull(now), style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: loading ? 'Checking in…' : 'Check In',
          icon: Icons.fingerprint,
          loading: loading,
          onPressed: () => _checkIn(context, ref),
        ),
      ],
    );
  }

  Widget _working(BuildContext context, WidgetRef ref, CheckInOutRecord record, DateTime now, bool loading) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatusChip(
          label: 'Currently Working',
          color: AppColors.success,
          background: AppColors.successBg,
          dot: false,
          icon: Icons.play_circle_outline,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Checked in', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 3),
                  Text(Fmt.time(record.checkInTime!), style: GoogleFontsSora.size18.copyWith(fontSize: 17)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Working duration', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 3),
                Text(
                  Fmt.duration(record.workingMinutes(now)),
                  style: GoogleFontsSora.size22.copyWith(fontSize: 27, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: loading ? 'Checking out…' : 'Check Out',
          icon: Icons.logout_rounded,
          loading: loading,
          onPressed: () => _confirmCheckOut(context, ref, record, now),
        ),
      ],
    );
  }

  Widget _completed(BuildContext context, CheckInOutRecord record) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatusChip(
          label: 'Workday Completed',
          color: AppColors.success,
          background: AppColors.successBg,
          dot: false,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check in', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 3),
                  Text(Fmt.time(record.checkInTime!), style: GoogleFontsSora.size18.copyWith(fontSize: 15)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check out', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 3),
                  Text(Fmt.time(record.checkOutTime!), style: GoogleFontsSora.size18.copyWith(fontSize: 15)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Total', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 3),
                Text(
                  Fmt.duration(record.checkOutTime!.difference(record.checkInTime!).inMinutes),
                  style: GoogleFontsSora.size18.copyWith(fontSize: 15, color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.push('/attendance/checkin'),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View timeline', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Now checks for permission/location errors and shows dialog
  Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(todayAttendanceProvider.notifier).checkIn();
      if (context.mounted) AppSnack.success(context, 'Checked in — have a great day!');
    } on AppFailure catch (e) {
      if (context.mounted) {
        if (e.message.contains('permission') || e.message.contains('location')) {
          _showLocationPermissionDialog(context);
        } else {
          AppSnack.error(context, e.message);
        }
      }
    }
  }

  // ✅ FIXED: Now checks for permission/location errors and shows dialog
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
      if (context.mounted) {
        if (e.message.contains('permission') || e.message.contains('location')) {
          _showLocationPermissionDialog(context);
        } else {
          AppSnack.error(context, e.message);
        }
      }
    }
  }

  // ✅ NEW: Helper method for location permission dialog
  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Permission Needed'),
        content: const Text(
          'Check-in requires location access. Please enable location permissions in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

/// Local copy of InfoRow to keep this widget self-contained inside the blue header.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))),
          Text(value, style: theme.textTheme.titleSmall?.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}