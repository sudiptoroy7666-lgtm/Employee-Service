import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../../core/providers/app_providers.dart';
import '../providers/visit_providers.dart';

class DayManagementScreen extends ConsumerWidget {
  const DayManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final dayState = ref.watch(dayManagementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Day Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                Text(Fmt.time(now), style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(Fmt.dateFull(now), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Day Status', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                if (dayState.isDayStarted) ...[
                  Row(
                    children: [
                      const Icon(Icons.play_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text('Day Started at ${dayState.startTime != null ? Fmt.time(dayState.startTime!) : "--:--"}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(Icons.pause_circle, color: AppColors.gray, size: 20),
                      const SizedBox(width: 8),
                      Text('Day not started yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!dayState.isDayStarted)
            PrimaryButton(
              label: 'Start Day',
              icon: Icons.play_arrow,
              onPressed: () async {
                await ref.read(dayManagementProvider.notifier).startDay();
                if (context.mounted) AppSnack.success(context, 'Day started successfully');
              },
            )
          else
            SecondaryButton(
              label: 'End Day',
              icon: Icons.stop,
              onPressed: () async {
                final confirmed = await ConfirmationBottomSheet.show(
                  context,
                  title: 'End Day',
                  confirmLabel: 'End Day',
                  danger: true,
                  body: const Text('Are you sure you want to end your day?'),
                );
                if (confirmed) {
                  await ref.read(dayManagementProvider.notifier).endDay();
                  if (context.mounted) AppSnack.success(context, 'Day ended successfully');
                }
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
