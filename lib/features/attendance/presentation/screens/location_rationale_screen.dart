import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';

class LocationRationaleScreen extends StatelessWidget {
  const LocationRationaleScreen({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LocationRationaleScreen()),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text(
                'Location Access Required',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'WorkPulse needs your location to verify you are at the office when checking in or out.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Point(icon: Icons.timer, text: 'Only used when you tap Check-In or Check-Out'),
                    const SizedBox(height: 12),
                    _Point(icon: Icons.visibility_off, text: 'Never tracked in the background'),
                    const SizedBox(height: 12),
                    _Point(icon: Icons.lock, text: 'Location data is only used for attendance'),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: 'Continue',
                icon: Icons.check_circle_outline,
                onPressed: () => Navigator.pop(context, true),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Not now', style: theme.textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Point({required this.icon, required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
