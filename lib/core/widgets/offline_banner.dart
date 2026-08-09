import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_providers.dart';
import '../theme/app_theme.dart';

class OfflineBanner extends ConsumerWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    
    return Column(
      children: [
        if (!isOnline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.warningBg,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You're offline. Some features may be unavailable.",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF93520A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
