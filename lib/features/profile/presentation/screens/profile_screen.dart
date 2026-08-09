import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/states.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final employee = profileAsync.valueOrNull ??
        ref.watch(authControllerProvider).valueOrNull;
    if (employee == null) {
      return AppScaffold(
        title: 'My Profile',
        body: profileAsync.when(
          loading: () => const LoadingSkeleton(blocks: 3),
          error: (e, _) => ErrorStateWidget(error: e, onRetry: () => ref.invalidate(profileProvider)),
          data: (_) => const SizedBox.shrink(),
        ),
      );
    }

    return AppScaffold(
      title: 'My Profile',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Reveal(
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
              child: Column(
                children: [
                  UserAvatar(name: employee.name, size: 82),
                  const SizedBox(height: 14),
                  Text(employee.name, style: theme.textTheme.displayMedium?.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(employee.designation, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _tag(employee.employeeId, AppColors.primary),
                      _tag(employee.department, AppColors.navy),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal Information', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Email', value: employee.email, icon: Icons.email_outlined),
                  const Divider(height: 18),
                  InfoRow(label: 'Phone', value: employee.phone, icon: Icons.phone_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            delay: const Duration(milliseconds: 140),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Work Information', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Employee ID', value: employee.employeeId, icon: Icons.badge_outlined),
                  const Divider(height: 18),
                  InfoRow(label: 'Department', value: employee.department, icon: Icons.apartment_outlined),
                  const Divider(height: 18),
                  InfoRow(label: 'Designation', value: employee.designation, icon: Icons.work_outline),
                  const Divider(height: 18),
                  InfoRow(label: 'Joining Date', value: Fmt.dateMedium(employee.joiningDate), icon: Icons.calendar_today_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            delay: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.grayBg, borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline, size: 17, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Profile information is managed by your HR team through the admin system. Contact HR to request changes.',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}