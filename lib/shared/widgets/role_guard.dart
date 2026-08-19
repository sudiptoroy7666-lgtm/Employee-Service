import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/role_providers.dart';
import '../../core/theme/app_theme.dart';

class RoleGuard extends ConsumerWidget {
  final String feature;
  final Widget child;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.feature,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAccess = ref.watch(canAccessFeatureProvider(feature));

    if (canAccess) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

class AccessDeniedWidget extends StatelessWidget {
  final String feature;

  const AccessDeniedWidget({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.grayBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, size: 40, color: AppColors.gray),
            ),
            const SizedBox(height: 20),
            Text(
              'Access Denied',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have permission to access $feature.\nPlease contact your supervisor.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
