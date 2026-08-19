import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/states.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../presentation/providers/statement_providers.dart';

class StatementScreen extends ConsumerStatefulWidget {
  const StatementScreen({super.key});

  @override
  ConsumerState<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends ConsumerState<StatementScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employee = ref.watch(authControllerProvider).valueOrNull;
    final statementAsync = ref.watch(statementProvider(_month));

    return Scaffold(
      appBar: AppBar(title: const Text('My Statement')),
      body: statementAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [LoadingSkeleton(blocks: 4)],
        ),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.invalidate(statementProvider(_month)),
        ),
        data: (statement) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              MonthSelector(
                month: _month,
                minMonth: DateTime(2026, 1),
                maxMonth: DateTime.now(),
                onChanged: (m) => setState(() => _month = DateTime(m.year, m.month)),
              ),
              const SizedBox(height: 16),

              Reveal(
                child: AppCard(
                  child: Row(
                    children: [
                      UserAvatar(name: employee?.name ?? 'Employee', size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(employee?.name ?? 'Employee', style: theme.textTheme.titleLarge),
                            const SizedBox(height: 3),
                            Text(
                              '${employee?.employeeId ?? ''} · ${employee?.department ?? ''}',
                              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 3),
                            Text(employee?.designation ?? '', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Reveal(
                delay: const Duration(milliseconds: 70),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attendance Summary', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      InfoRow(label: 'Working Days', value: '${statement.attendance.workingDays}'),
                      const Divider(height: 18),
                      InfoRow(label: 'Present', value: '${statement.attendance.present}', valueColor: AppColors.success),
                      const Divider(height: 18),
                      InfoRow(label: 'Late', value: '${statement.attendance.late}', valueColor: AppColors.warning),
                      const Divider(height: 18),
                      InfoRow(label: 'Absent', value: '${statement.attendance.absent}', valueColor: AppColors.danger),
                      const Divider(height: 18),
                      InfoRow(label: 'Leave', value: '${statement.attendance.leaveDays} ${statement.attendance.leaveDays == 1 ? 'day' : 'days'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Reveal(
                delay: const Duration(milliseconds: 130),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Work Summary', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (statement.work != null) ...[
                        InfoRow(label: 'Regular Hours', value: Fmt.duration(statement.work!.regularMinutes)),
                        const Divider(height: 18),
                        InfoRow(label: 'Overtime', value: Fmt.duration(statement.work!.overtimeMinutes), valueColor: AppColors.success),
                        const Divider(height: 18),
                        InfoRow(label: 'Total Hours', value: Fmt.duration(statement.work!.totalMinutes), valueColor: AppColors.primary),
                      ] else
                        const Text('No work data available'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Reveal(
                delay: const Duration(milliseconds: 190),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Leave Summary', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      InfoRow(label: 'Leave Used', value: '${statement.leave.usedDays} ${statement.leave.usedDays == 1 ? 'day' : 'days'}'),
                      const Divider(height: 18),
                      InfoRow(label: 'Leave Remaining', value: '${statement.leave.remainingDays} days', valueColor: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Reveal(
                delay: const Duration(milliseconds: 250),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Summary', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (statement.payment != null) ...[
                        InfoRow(label: 'Gross Pay', value: Fmt.money(statement.payment!.grossPay, statement.payment!.currency)),
                        const Divider(height: 18),
                        InfoRow(
                          label: 'Deductions',
                          value: '−${Fmt.money(statement.payment!.deductions, statement.payment!.currency)}',
                          valueColor: AppColors.danger,
                        ),
                        const Divider(height: 18),
                        InfoRow(
                          label: 'Net Pay',
                          value: Fmt.money(statement.payment!.netPay, statement.payment!.currency),
                          valueColor: AppColors.success,
                        ),
                      ] else
                        const Text('No payment data available for this month'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
