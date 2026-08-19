import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/attendance.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';
import 'cards.dart';

import '../../../../features/notifications/presentation/providers/notification_providers.dart';

/// Scaffold wrapper used by inner pages: canvas background + app bar + content width cap.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBack = true,
    this.actions,
    this.floatingActionButton,
    this.header,
  });

  final Widget body;
  final String? title;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
        leading: showBack
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        )
            : null,
        automaticallyImplyLeading: showBack,
        title: Text(title!),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (header != null) header!,
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.size = 40, this.imageUrl, this.light = false});
  final String name;
  final double size;
  final String? imageUrl;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: light ? Colors.white : AppColors.primary.withValues(alpha: 0.12),
        border: Border.all(color: light ? Colors.white.withValues(alpha: 0.4) : Colors.transparent, width: 2),
      ),
      child: Center(
        child: Text(
          Fmt.initials(name),
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            fontSize: size * 0.34,
            color: light ? AppColors.primary : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class NotificationButton extends ConsumerWidget {
  const NotificationButton({super.key, this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: light ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.push('/notifications'),
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                '$unread',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, height: 1),
              ),
            ),
          ),
      ],
    );
  }
}

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key, required this.month, required this.onChanged, this.minMonth, this.maxMonth});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;
  final DateTime? minMonth;
  final DateTime? maxMonth;

  bool get _canPrev => minMonth == null || DateTime(month.year, month.month - 1).isAfter(DateTime(minMonth!.year, minMonth!.month - 1));
  bool get _canNext => maxMonth == null || DateTime(month.year, month.month + 1).isBefore(DateTime(maxMonth!.year, maxMonth!.month + 1));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _canPrev ? () => onChanged(DateTime(month.year, month.month - 1)) : null,
          ),
          Text(Fmt.monthYear(month), style: GoogleFontsSora.size18.copyWith(fontSize: 15)),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _canNext ? () => onChanged(DateTime(month.year, month.month + 1)) : null,
          ),
        ],
      ),
    );
  }
}

/// Vertical event timeline (check-in screen).
class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({super.key, required this.events});

  /// (time, label, icon, color)
  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('No events recorded yet.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(events.length, (i) {
        final e = events[i];
        final isLast = i == events.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: e.color.withValues(alpha: 0.14), shape: BoxShape.circle),
                    child: Icon(e.icon, size: 15, color: e.color),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 3), color: AppColors.border)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(e.label, style: theme.textTheme.titleSmall)),
                      Text(Fmt.time(e.time), style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class TimelineEvent {
  const TimelineEvent({required this.time, required this.label, required this.icon, required this.color});
  final DateTime time;
  final String label;
  final IconData icon;
  final Color color;
}

/// Pulsing "live" indicator dot.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, this.color = AppColors.success, this.size = 8});
  final Color color;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: 0.45 + 0.55 * (1 - _c.value),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

AttendanceStatus? attendanceStatusFromCalendar(Map<DateTime, AttendanceStatus> calendar, DateTime date) =>
    calendar[DateUtils.dateOnly(date)];