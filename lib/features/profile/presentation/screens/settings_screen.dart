import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/location_service.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

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

  void _languageSheet(BuildContext context) {
    showInfoSheet(
      context,
      icon: Icons.language_outlined,
      title: 'English (UK)',
      message: 'Additional languages will be available in a future release.',
    );
  }

  Future<void> _viewStoredTokens(BuildContext context, WidgetRef ref) async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.readToken();
    final refreshToken = await storage.readRefreshToken();
    final userId = await storage.readUserId();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stored Tokens'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User ID:', style: Theme.of(context).textTheme.labelMedium),
              SelectableText(
                userId ?? 'null',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text('Access Token:', style: Theme.of(context).textTheme.labelMedium),
              SelectableText(
                token ?? 'null',
                maxLines: 4,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
              ),
              const SizedBox(height: 12),
              Text('Refresh Token:', style: Theme.of(context).textTheme.labelMedium),
              SelectableText(
                refreshToken ?? 'null',
                maxLines: 4,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _forceTokenRefresh(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    AppSnack.info(context, 'Refreshing token...');

    try {
      final apiClient = ref.read(apiClientProvider);
      final storage = ref.read(tokenStorageProvider);

      final refreshToken = await storage.readRefreshToken();
      if (refreshToken == null) {
        if (context.mounted) AppSnack.error(context, 'No refresh token stored. Login first.');
        return;
      }

      debugPrint('🔄 Old token: ${(await storage.readToken())?.substring(0, 20)}...');

      final response = await apiClient.dio.post(
        ApiEndpoints.refresh,
        options: Options(headers: {
          ApiConfig.clientTypeHeader: ApiConfig.clientTypeValue,
          ApiConfig.refreshTokenHeader: refreshToken,
        }),
      );

      final data = response.data as Map<String, dynamic>?;
      final newToken = data?['accessToken'] as String? ?? data?['token'] as String?;

      if (newToken != null && newToken.isNotEmpty) {
        await storage.write(token: newToken, refreshToken: refreshToken);
        debugPrint('✅ New token: ${newToken.substring(0, 20)}...');
        if (context.mounted) AppSnack.success(context, 'Token refreshed successfully!');
      } else {
        if (context.mounted) AppSnack.error(context, 'Refresh succeeded but no token returned.');
      }
    } catch (e) {
      debugPrint('❌ Refresh failed: $e');
      if (context.mounted) AppSnack.error(context, 'Token refresh failed: $e');
    }
  }

  Future<void> _expireTokenNow(BuildContext context, WidgetRef ref) async {
    final storage = ref.read(tokenStorageProvider);
    const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwiZXhwIjoxfQ.invalid';
    await storage.write(token: expiredToken);
    if (context.mounted) {
      AppSnack.warning(context, 'Token expired! Next API call will trigger auto-refresh.');
    }
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
            const Divider(height: 1, indent: 54),
            _SettingTile(
              icon: Icons.password_outlined,
              title: 'Change Password',
              onTap: () => showInfoSheet(
                context,
                icon: Icons.password_outlined,
                title: 'Managed by HR',
                message: 'Password changes are handled through HR. Please contact peopleops@softzentech.co.uk for assistance.',
              ),
            ),
          ]),
          const SizedBox(height: 14),
          _section(theme, 'Preferences', [
            SwitchListTile.adaptive(
              value: LocationService.forceOfficeLocation,
              onChanged: (v) => setState(() => LocationService.forceOfficeLocation = v),
              secondary: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.location_on_outlined, size: 19, color: AppColors.warning),
              ),
              title: Text('Force Office Location', style: theme.textTheme.titleSmall?.copyWith(fontSize: 14)),
              subtitle: Text(
                'Use SoftZen IT Banani coordinates for check-in (testing)',
                style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              dense: true,
            ),
            const Divider(height: 1, indent: 54),
            _SettingTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English (UK)',
              onTap: () => _languageSheet(context),
            ),
            const Divider(height: 1, indent: 54),
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

          // ─── DEBUG SECTION — remove before production ───
          _section(theme, '🛠 Developer Tools (Debug)', [
            _SettingTile(
              icon: Icons.key,
              title: 'View Stored Tokens',
              subtitle: 'Inspect access & refresh tokens',
              iconTint: AppColors.navy,
              onTap: () => _viewStoredTokens(context, ref),
            ),
            const Divider(height: 1, indent: 54),
            _SettingTile(
              icon: Icons.refresh,
              title: 'Force Token Refresh',
              subtitle: 'Manually call /api/auth/refresh',
              iconTint: AppColors.primary,
              onTap: () => _forceTokenRefresh(context, ref),
            ),
            const Divider(height: 1, indent: 54),
            _SettingTile(
              icon: Icons.timer_off,
              title: 'Expire Token Now',
              subtitle: 'Trigger auto-refresh on next request',
              iconTint: AppColors.warning,
              onTap: () => _expireTokenNow(context, ref),
            ),
          ]),
          // ─── END DEBUG SECTION ───

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
    this.subtitle,
    this.titleColor,
    this.iconTint,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                  ],
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