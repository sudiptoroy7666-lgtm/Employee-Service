import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../domain/models/visit.dart';
import '../../domain/models/visit_status.dart';

class VisitCard extends StatelessWidget {
  final Visit visit;
  final VoidCallback? onTap;

  const VisitCard({super.key, required this.visit, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.add_location, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit.clientName, style: theme.textTheme.titleSmall),
                    Text(
                      '${visit.clientType.label} · ${visit.visitType.label}',
                      style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _VisitStatusChip(status: visit.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.gray),
              const SizedBox(width: 4),
              Text(
                Fmt.time(visit.scheduledTime),
                style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              if (visit.checkInTime != null) ...[
                const Icon(Icons.login, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  Fmt.time(visit.checkInTime!),
                  style: theme.textTheme.labelMedium?.copyWith(color: AppColors.success),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitStatusChip extends StatelessWidget {
  final VisitStatus status;

  const _VisitStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      VisitStatus.pending => (AppColors.warning, AppColors.warningBg),
      VisitStatus.checkedIn => (AppColors.primary, AppColors.infoBg),
      VisitStatus.completed => (AppColors.success, AppColors.successBg),
      VisitStatus.cancelled => (AppColors.danger, AppColors.dangerBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
