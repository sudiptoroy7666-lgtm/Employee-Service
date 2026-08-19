import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';

/// Shown when a web-only role (Admin, HR, Factory Manager, etc.)
/// tries to log into the mobile field app.
///
/// Per PDF Section 4.1, these roles should use the Web Panel.
class UnsupportedRoleScreen extends ConsumerWidget {
  const UnsupportedRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final employee = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.warningBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.desktop_windows_outlined,
                    size: 50,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Web Panel Required',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Your role (${employee?.designation ?? 'Admin/Manager'}) requires the Circle Seed ERP Web Panel.\n\nThis mobile app is designed for Marketing Executives and Supervisors who work in the field.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Info card
                AppCard(
                  color: AppColors.infoBg,
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.link, color: AppColors.primary, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please use a desktop browser to access:',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          // Could use url_launcher to open the web panel
                          await Clipboard.setData(
                            const ClipboardData(text: 'https://circleseed.com/erp'),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Web panel URL copied to clipboard'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'https://circleseed.com/erp',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Roles that use this app
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This app is for:',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      _RoleRow(
                        icon: Icons.directions_walk,
                        label: 'Marketing Executive',
                        desc: 'Field visits, orders, collections',
                      ),
                      const SizedBox(height: 8),
                      _RoleRow(
                        icon: Icons.leaderboard,
                        label: 'Supervisor',
                        desc: 'Team monitoring, approvals, KPIs',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Logout button
                SecondaryButton(
                  label: 'Logout',
                  icon: Icons.logout,
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;

  const _RoleRow({
    required this.icon,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text(
                desc,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
