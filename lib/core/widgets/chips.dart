import 'package:flutter/material.dart';

import '../models/attendance.dart';
import '../models/leave.dart';
import '../models/payment.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color, required this.background, this.icon, this.dot = true});

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
            ] else if (dot) ...[
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
            ],
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _Meta {
  const _Meta(this.color, this.bg);
  final Color color;
  final Color bg;
}

_Meta _attendanceMeta(AttendanceStatus s) {
  switch (s) {
    case AttendanceStatus.present:
      return const _Meta(AppColors.success, AppColors.successBg);
    case AttendanceStatus.late:
      return const _Meta(AppColors.warning, AppColors.warningBg);
    case AttendanceStatus.absent:
      return const _Meta(AppColors.danger, AppColors.dangerBg);
    case AttendanceStatus.holiday:
      return const _Meta(AppColors.primary, AppColors.infoBg);
    case AttendanceStatus.weekend:
      return const _Meta(AppColors.gray, AppColors.grayBg);
  }
}

class AttendanceStatusChip extends StatelessWidget {
  const AttendanceStatusChip({super.key, required this.status});
  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final m = _attendanceMeta(status);
    return StatusChip(label: status.label, color: m.color, background: m.bg);
  }
}

class LeaveStatusChip extends StatelessWidget {
  const LeaveStatusChip({super.key, required this.status});
  final LeaveStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = switch (status) {
      LeaveStatus.pending => (AppColors.warning, AppColors.warningBg, Icons.schedule_outlined),
      LeaveStatus.approved => (AppColors.success, AppColors.successBg, Icons.check_circle_outline),
      LeaveStatus.rejected => (AppColors.danger, AppColors.dangerBg, Icons.cancel_outlined),
    };
    return StatusChip(label: status.label, color: color, background: bg, icon: icon, dot: false);
  }
}

class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({super.key, required this.status, this.onDark = false});
  final PaymentStatus status;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      PaymentStatus.paid => (AppColors.success, AppColors.successBg),
      PaymentStatus.pending => (AppColors.warning, AppColors.warningBg),
      PaymentStatus.processing => (AppColors.primary, AppColors.infoBg),
      PaymentStatus.failed => (AppColors.danger, AppColors.dangerBg),
    };
    if (onDark) {
      return StatusChip(label: status.label, color: Colors.white, background: Colors.white.withValues(alpha: 0.16), dot: false,
          icon: status == PaymentStatus.paid ? Icons.check_circle_outline : null);
    }
    return StatusChip(label: status.label, color: color, background: bg, dot: false,
        icon: status == PaymentStatus.paid ? Icons.check_circle_outline : null);
  }
}