import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/notification.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/states.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  AppNotificationType? _filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
              child: Text('Mark all read', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
        ],
      ),
      body: notificationsAsync.when(
         loading: () => ListView(padding: const EdgeInsets.all(16), children: const [LoadingSkeleton(blocks: 4)]),
        error: (e, _) => ErrorStateWidget(error: e, onRetry: () => ref.read(notificationsProvider.notifier).refresh()),
        data: (notifications) {
          final filtered = _filter == null
              ? notifications
              : notifications.where((n) => n.type == _filter).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('All', null),
                    for (final t in AppNotificationType.values) _chip(t.label, t),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (filtered.isEmpty)
                EmptyStateWidget(
                  icon: Icons.notifications_none_rounded,
                  title: _filter == null ? 'No new notifications' : 'No ${_filter!.label.toLowerCase()} notifications',
                  message: "You're all caught up. Updates about your work will appear here.",
                )
              else
                ...List.generate(filtered.length, (i) {
                  final n = filtered[i];
                  return Reveal(
                    delay: Duration(milliseconds: i * 40),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NotificationTile(
                        notification: n,
                        onTap: n.isRead ? null : () => ref.read(notificationsProvider.notifier).markRead(n.id),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, AppNotificationType? type) {
    final selected = _filter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => setState(() => _filter = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.primary : Theme.of(context).dividerColor),
          ),
          child: Text(
            label,
            style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, this.onTap});
  final AppNotification notification;
  final VoidCallback? onTap;

  (IconData, Color) get _meta {
    switch (notification.type) {
      case AppNotificationType.attendance:
        return (Icons.fingerprint, AppColors.primary);
      case AppNotificationType.leave:
        return (Icons.beach_access, AppColors.warning);
      case AppNotificationType.payment:
        return (Icons.payments_outlined, AppColors.success);
      case AppNotificationType.system:
        return (Icons.campaign_outlined, AppColors.gray);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _meta;
    return AppCard(
      onTap: onTap,
      color: notification.isRead ? null : color.withValues(alpha: 0.045),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      Fmt.relative(notification.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(color: AppColors.gray),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.message, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text(
                  notification.type.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(color: color, letterSpacing: 0.8, fontWeight: FontWeight.w700, fontSize: 10),
                ),
              ],
            ),
          ),
          if (!notification.isRead) ...[
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }
}