import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(theme, 'Account', [
            _SettingTile(icon: Icons.person_outline, title: 'My Profile', onTap: () => context.push('/profile')),
          ]),
          const SizedBox(height: 14),
          _section(theme, 'Support', [
            _SettingTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () => context.push('/help')),
            const Divider(height: 1, indent: 54),
            _SettingTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () => context.push('/legal/privacy')),
            const Divider(height: 1, indent: 54),
            _SettingTile(icon: Icons.description_outlined, title: 'Terms & Conditions', onTap: () => context.push('/legal/terms')),
          ]),
          const SizedBox(height: 14),
          _section(theme, 'Account Actions', [
            _SettingTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              titleColor: AppColors.danger,
              iconTint: AppColors.danger,
              onTap: () => _logout(context, ref),
            ),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _section(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.gray, letterSpacing: 1.1, fontWeight: FontWeight.w700),
          ),
        ),
        AppCard(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: children)),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.iconTint,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconTint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = iconTint ?? AppColors.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(color: titleColor, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.gray),
          ],
        ),
      ),
    );
  }
}