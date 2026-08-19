import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../../core/widgets/states.dart';
import '../../../visits/domain/models/marketing_client.dart';
import '../../../visits/presentation/providers/stakeholder_providers.dart';
import '../../domain/models/complaint.dart';
import '../providers/complaint_providers.dart';

class NewComplaintScreen extends ConsumerStatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  ConsumerState<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends ConsumerState<NewComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  MarketingClient? _selectedClient;
  ComplaintPriority _priority = ComplaintPriority.medium;
  bool _submitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Submit Complaint',
      confirmLabel: 'Submit',
      confirmIcon: Icons.report_problem,
      body: Column(
        children: [
          InfoRow(label: 'Subject', value: _subjectController.text.trim()),
          const Divider(height: 18),
          InfoRow(
            label: 'Client',
            value: _selectedClient?.displayName ?? 'General',
          ),
          const Divider(height: 18),
          InfoRow(label: 'Priority', value: _priority.label),
          const SizedBox(height: 8),
          Text(
            'This complaint will be submitted to the management team.',
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
      final complaint = Complaint(
        id: '',
        clientName: _selectedClient?.displayName ?? 'General',
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        submittedDate: DateTime.now(),
        status: ComplaintStatus.open,
        priority: _priority,
      );

      final repo = ref.watch(complaintRepositoryProvider);
      await repo.createComplaint(complaint);

      if (mounted) {
        AppSnack.success(context, 'Complaint submitted successfully.');
        ref.invalidate(complaintsProvider);
        context.pop();
      }
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    } catch (e) {
      if (mounted) AppSnack.error(context, 'Failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stakeholdersAsync = ref.watch(stakeholdersProvider);

    return AppScaffold(
      title: 'New Complaint',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Client Selection (Optional)
            AppCard(
              child: stakeholdersAsync.maybeWhen(
                data: (stakeholders) => DropdownButtonFormField<MarketingClient>(
                  value: _selectedClient,
                  decoration: const InputDecoration(
                    labelText: 'Related Client (Optional)',
                    prefixIcon: Icon(Icons.store_outlined),
                    hintText: 'Select a client',
                  ),
                  items: stakeholders.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(
                        '${s.displayName} (${s.typeLabel})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedClient = val),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),

            // Subject
            AppCard(
              child: TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject *',
                  prefixIcon: Icon(Icons.title),
                  hintText: 'e.g., Seed quality issue',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            AppCard(
              child: TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'Describe the issue in detail...',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
            ),
            const SizedBox(height: 16),

            // Priority
            AppCard(
              child: DropdownButtonFormField<ComplaintPriority>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: ComplaintPriority.values.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p.label));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _priority = val);
                },
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              label: _submitting ? 'Submitting...' : 'Submit Complaint',
              icon: Icons.report_problem,
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
