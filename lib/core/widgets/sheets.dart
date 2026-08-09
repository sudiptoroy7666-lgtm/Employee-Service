import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'buttons.dart';
import 'cards.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.confirmIcon,
    this.danger = false,
  });

  final String title;
  final Widget body;
  final String confirmLabel;
  final IconData? confirmIcon;
  final bool danger;

  static Future<bool> show(
      BuildContext context, {
        required String title,
        required Widget body,
        required String confirmLabel,
        IconData? confirmIcon,
        bool danger = false,
      }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ConfirmationBottomSheet(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        confirmIcon: confirmIcon,
        danger: danger,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 18),
            Text(title, style: GoogleFontsSora.size18.copyWith(fontSize: 18)),
            const SizedBox(height: 14),
            body,
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: danger ? ElevatedButton.styleFrom(backgroundColor: AppColors.danger) : null,
                      onPressed: () => Navigator.pop(context, true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (confirmIcon != null) ...[Icon(confirmIcon, size: 18), const SizedBox(width: 8)],
                          Text(confirmLabel.toUpperCase(), style: const TextStyle(letterSpacing: 0.6)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple informational bottom sheet (used for future-ready placeholders).
Future<void> showInfoSheet(BuildContext context, {required IconData icon, required String title, required String message}) {
  final theme = Theme.of(context);
  return showModalBottomSheet(
    context: context,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 22),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: AppColors.infoBg, shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Got it', onPressed: () => Navigator.pop(context), height: 48),
          ],
        ),
      ),
    ),
  );
}

class AppSnack {
  AppSnack._();

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success, Icons.check_circle_outline);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.danger, Icons.error_outline);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.navy, Icons.info_outline);

  static void warning(BuildContext context, String message) =>
      _show(context, message, AppColors.warning, Icons.warning_amber_rounded);
}