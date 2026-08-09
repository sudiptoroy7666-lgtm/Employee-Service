import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Log Out',
      confirmLabel: 'Logout',
      danger: true,
      confirmIcon: Icons.logout_rounded,
      body: Text(
        'Are you sure you want to log out of your employee account?',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final employee = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Reveal(
            child: AppCard(
              onTap: () => context.push('/profile'),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  UserAvatar(name: employee?.name ?? '?', size: 54),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee?.name ?? 'Employee', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 3),
                        Text(
                          '${employee?.employeeId ?? ''} · ${employee?.designation ?? ''}',
                          style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.gray),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Reveal(
            delay: const Duration(milliseconds: 70),
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _MenuTile(icon: Icons.summarize_outlined, tint: AppColors.navy, title: 'My Statement', onTap: () => context.push('/statement')),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(icon: Icons.person_outline, tint: AppColors.success, title: 'My Profile', onTap: () => context.push('/profile')),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(icon: Icons.settings_outlined, tint: AppColors.gray, title: 'Settings', onTap: () => context.push('/settings')),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(icon: Icons.help_outline, tint: AppColors.warning, title: 'Help & Support', onTap: () => context.push('/help')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            delay: const Duration(milliseconds: 130),
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _MenuTile(
                icon: Icons.logout_rounded,
                tint: AppColors.danger,
                title: 'Logout',
                titleColor: AppColors.danger,
                onTap: () => _logout(context, ref),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: Text(
              '${AppConstants.appName} ${AppConstants.version}\n${AppConstants.companyName}',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.gray, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: tint.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, size: 19, color: tint),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: titleColor, fontSize: 14)),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.gray),
          ],
        ),
      ),
    );
  }
}