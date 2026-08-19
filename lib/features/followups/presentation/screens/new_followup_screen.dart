import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../../core/widgets/states.dart';
import '../../../leads/domain/models/lead.dart';
import '../../../leads/presentation/providers/lead_providers.dart';
import '../../domain/models/followup.dart';
import '../providers/followup_providers.dart';

class NewFollowUpScreen extends ConsumerStatefulWidget {
  const NewFollowUpScreen({super.key});

  @override
  ConsumerState<NewFollowUpScreen> createState() => _NewFollowUpScreenState();
}

class _NewFollowUpScreenState extends ConsumerState<NewFollowUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  Lead? _selectedLead;
  DateTime _followUpDate = DateTime.now();
  FollowUpOutcome? _outcome;
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _followUpDate = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLead == null) {
      AppSnack.error(context, 'Please select a lead.');
      return;
    }

    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Record Follow-Up',
      confirmLabel: 'Save',
      confirmIcon: Icons.follow_the_signs,
      body: Column(
        children: [
          InfoRow(label: 'Lead', value: _selectedLead!.name),
          const Divider(height: 18),
          InfoRow(label: 'Date', value: Fmt.dateMedium(_followUpDate)),
          if (_outcome != null) ...[
            const Divider(height: 18),
            InfoRow(label: 'Outcome', value: _outcome!.label),
          ],
          const SizedBox(height: 8),
          Text(
            'This follow-up will be recorded in the system.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (!confirmed || !mounted) return;

    setState(() => _submitting = true);

    try {
      await ref.read(createFollowUpControllerProvider.notifier).submit(
        leadId: _selectedLead!.id,
        followUpDate: _followUpDate,
        notes: _notesController.text,
        outcome: _outcome,
      );

      if (mounted) {
        AppSnack.success(context, 'Follow-up recorded successfully.');
        context.pop();
      }
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    } catch (e) {
      if (mounted) AppSnack.error(context, 'Failed to record follow-up.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsProvider);

    return AppScaffold(
      title: 'Record Follow-Up',
      body: leadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(error: e),
        data: (leads) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: DropdownButtonFormField<Lead>(
                  value: _selectedLead,
                  decoration: const InputDecoration(
                    labelText: 'Select Lead *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: leads.map((lead) {
                    return DropdownMenuItem(
                      value: lead,
                      child: Text(
                        '${lead.name} (${lead.contact})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedLead = val),
                  validator: (v) => v == null ? 'Please select a lead' : null,
                ),
              ),
              const SizedBox(height: 16),

              AppCard(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Follow-Up Date',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    child: Text(Fmt.dateMedium(_followUpDate)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              AppCard(
                child: DropdownButtonFormField<FollowUpOutcome>(
                  value: _outcome,
                  decoration: const InputDecoration(
                    labelText: 'Outcome (Optional)',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: FollowUpOutcome.values.map((o) {
                    return DropdownMenuItem(value: o, child: Text(o.label));
                  }).toList(),
                  onChanged: (val) => setState(() => _outcome = val),
                ),
              ),
              const SizedBox(height: 16),

              AppCard(
                child: TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.note_outlined),
                    hintText: 'What was discussed during this follow-up...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                label: _submitting ? 'Saving...' : 'Save Follow-Up',
                icon: Icons.follow_the_signs,
                loading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
