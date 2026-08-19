import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../../shared/models/user_role.dart';
import '../../../../shared/providers/role_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';

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
        'Are you sure you want to log out of your account?',
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
    final unread = ref.watch(unreadCountProvider);
    final role = ref.watch(currentUserRoleProvider);

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
                          '${employee?.employeeId ?? ''} • ${employee?.designation ?? ''}',
                          style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
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
                  _MenuTile(
                    icon: Icons.summarize_outlined,
                    tint: AppColors.navy,
                    title: 'My Statement',
                    onTap: () => context.push('/statement'),
                  ),
                  const Divider(height: 1, indent: 54),
                //  _MenuTile(icon: Icons.notifications_outlined,tint: AppColors.primary,title: 'Notifications',badge: unread > 0 ? '$unread' : null,onTap: () => context.push('/notifications'),),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(
                    icon: Icons.account_balance_wallet_outlined,
                    tint: AppColors.success,
                    title: 'My Commissions',
                    onTap: () => context.push('/commissions'),
                  ),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(
                    icon: Icons.payments_outlined,
                    tint: AppColors.warning,
                    title: 'Payments',
                    onTap: () => context.push('/payments'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          Reveal(
            delay: const Duration(milliseconds: 100),
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.add_location,
                    tint: AppColors.primary,
                    title: 'My Visits',
                    onTap: () => context.push('/visits'),
                  ),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(
                    icon: Icons.person_add,
                    tint: AppColors.warning,
                    title: 'My Leads',
                    onTap: () => context.push('/leads'),
                  ),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(
                    icon: Icons.follow_the_signs,
                    tint: AppColors.navy,
                    title: 'Follow-Ups',
                    onTap: () => context.push('/followups'),
                  ),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(
                    icon: Icons.campaign,
                    tint: AppColors.success,
                    title: 'Market Updates',
                    onTap: () => context.push('/market-updates'),
                  ),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(
                    icon: Icons.attach_money,
                    tint: AppColors.primary,
                    title: 'Collections',
                    onTap: () => context.push('/collections'),
                  ),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(
                    icon: Icons.report_problem,
                    tint: AppColors.danger,
                    title: 'Complaints',
                    onTap: () => context.push('/complaints'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          if (role == UserRole.supervisor) ...[
            Reveal(
              delay: const Duration(milliseconds: 130),
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.group,
                      tint: AppColors.primary,
                      title: 'Team Overview',
                      onTap: () => context.push('/dashboard'),
                    ),
                    const Divider(height: 1, indent: 54),
                    _MenuTile(
                      icon: Icons.event_available,
                      tint: AppColors.success,
                      title: 'Attendance',
                      onTap: () => context.push('/attendance'),
                    ),
                    const Divider(height: 1, indent: 54),
                    _MenuTile(
                      icon: Icons.beach_access,
                      tint: AppColors.warning,
                      title: 'Leave Requests',
                      onTap: () => context.push('/leave/new'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          Reveal(
            delay: const Duration(milliseconds: 160),
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.settings_outlined,
                    tint: AppColors.gray,
                    title: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                  const Divider(height: 1, indent: 54),
                  _MenuTile(
                    icon: Icons.help_outline,
                    tint: AppColors.warning,
                    title: 'Help & Support',
                    onTap: () => context.push('/help'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          Reveal(
            delay: const Duration(milliseconds: 190),
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
    this.badge,
    this.titleColor,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final VoidCallback onTap;
  final String? badge;
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
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(999)),
                child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, size: 18, color: AppColors.gray),
          ],
        ),
      ),
    );
  }
}
