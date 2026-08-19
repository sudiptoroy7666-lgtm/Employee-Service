import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/leave.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../providers/leave_providers.dart';

class NewLeaveRequestScreen extends ConsumerStatefulWidget {
  const NewLeaveRequestScreen({super.key});

  @override
  ConsumerState<NewLeaveRequestScreen> createState() => _NewLeaveRequestScreenState();
}

class _NewLeaveRequestScreenState extends ConsumerState<NewLeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  LeaveType? _type;
  DateTime? _start;
  DateTime? _end;
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int get _days => (_start != null && _end != null) ? _businessDays(_start!, _end!) : 0;

  LeaveBalance? get _balance {
    final balances = ref.read(leaveBalanceProvider).valueOrNull;
    if (balances == null || _type == null) return null;
    return balances.where((b) => b.type == _type).firstOrNull;
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _start = picked;
      if (_end != null && _end!.isBefore(_start!)) _end = _start;
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end ?? _start ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: _start ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _end = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Submit Leave Request',
      confirmLabel: 'Submit',
      confirmIcon: Icons.send_outlined,
      body: Column(
        children: [
          InfoRow(label: 'Leave type', value: _type!.label),
          const Divider(height: 18),
          InfoRow(label: 'Dates', value: Fmt.dateRange(_start!, _end!)),
          const Divider(height: 18),
          InfoRow(label: 'Duration', value: '$_days ${_days == 1 ? 'working day' : 'working days'}', valueColor: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            'Your request will be sent to HR for approval.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
    if (!confirmed || !mounted) return;

    setState(() => _submitting = true);
    try {
      await ref.read(leaveRequestsProvider.notifier).submit(
        NewLeaveRequest(
          leaveType: _type!,
          startDate: _start!,
          endDate: _end!,
          numberOfDays: _days,
          reason: _reasonController.text.trim(),
        ),
      );
      if (!mounted) return;
      AppSnack.success(context, 'Leave request submitted for approval.');
      context.pop();
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = _balance;

    return AppScaffold(
      title: 'New Leave Request',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (balance != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.event_available, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${balance.type.label}: ${balance.remainingDays} of ${balance.totalDays} days remaining',
                      style: theme.textTheme.labelMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<LeaveType>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Leave Type', prefixIcon: Icon(Icons.category_outlined)),
                  items: LeaveType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (t) => setState(() => _type = t),
                  validator: (v) => v == null ? 'Please select a leave type' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickStart,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Start Date', prefixIcon: Icon(Icons.event_outlined)),
                          child: Text(
                            _start == null ? 'Select' : Fmt.dateMedium(_start!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _start == null ? AppColors.gray : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickEnd,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'End Date', prefixIcon: Icon(Icons.event_outlined)),
                          child: Text(
                            _end == null ? 'Select' : Fmt.dateMedium(_end!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _end == null ? AppColors.gray : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.grayBg.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_outlined, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text('Duration', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      const Spacer(),
                      Text(
                        _days > 0 ? '$_days ${_days == 1 ? 'working day' : 'working days'}' : '—',
                        style: GoogleFontsSora.size18.copyWith(fontSize: 15, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Briefly describe why you need this leave…',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please provide a reason';
                    if (v.trim().length < 10) return 'Reason should be at least 10 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => AppSnack.info(context, 'Attachments will be supported once the backend enables file uploads.'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gray.withValues(alpha: 0.5), style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.attach_file, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('Attach document (optional)', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                PrimaryButton(
                  label: _submitting ? 'Submitting…' : 'Submit Request',
                  icon: Icons.send_outlined,
                  loading: _submitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

int _businessDays(DateTime start, DateTime end) {
  var count = 0;
  var cursor = DateTime(start.year, start.month, start.day);
  final last = DateTime(end.year, end.month, end.day);
  while (!cursor.isAfter(last)) {
    if (cursor.weekday != DateTime.saturday && cursor.weekday != DateTime.sunday) count++;
    cursor = cursor.add(const Duration(days: 1));
  }
  return count;
}