import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../providers/lead_providers.dart';

class NewLeadScreen extends ConsumerStatefulWidget {
  const NewLeadScreen({super.key});

  @override
  ConsumerState<NewLeadScreen> createState() => _NewLeadScreenState();
}

class _NewLeadScreenState extends ConsumerState<NewLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _companyController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedSeedInterest;
  bool _submitting = false;

  static const _seedInterests = [
    'Rice Seeds',
    'Maize Seeds',
    'Wheat Seeds',
    'Vegetable Seeds',
    'Brinjal Seeds',
    'Tomato Seeds',
    'Multiple / Mixed',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Register Lead',
      confirmLabel: 'Register',
      confirmIcon: Icons.person_add,
      body: Column(
        children: [
          InfoRow(label: 'Name', value: _nameController.text.trim()),
          const Divider(height: 18),
          InfoRow(label: 'Contact', value: _contactController.text.trim()),
          if (_companyController.text.trim().isNotEmpty) ...[
            const Divider(height: 18),
            InfoRow(label: 'Company', value: _companyController.text.trim()),
          ],
          if (_selectedSeedInterest != null) ...[
            const Divider(height: 18),
            InfoRow(label: 'Seed Interest', value: _selectedSeedInterest!),
          ],
          const SizedBox(height: 8),
          Text(
            'This lead will be added to your pipeline.',
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
      await ref.read(createLeadControllerProvider.notifier).submit(
        name: _nameController.text,
        contact: _contactController.text,
        company: _companyController.text,
        notes: _notesController.text,
      );

      if (mounted) {
        AppSnack.success(context, 'Lead registered successfully.');
        context.pop();
      }
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    } catch (e) {
      if (mounted) AppSnack.error(context, 'Failed to register lead. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register New Lead',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Lead Name *',
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'e.g., Karim Seeds & Fertilizers',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Lead name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number *',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: 'e.g., 01700000000',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Contact number is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: 'Company / Shop Name (Optional)',
                      prefixIcon: Icon(Icons.store_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            AppCard(
              child: DropdownButtonFormField<String>(
                value: _selectedSeedInterest,
                decoration: const InputDecoration(
                  labelText: 'Seed Interest',
                  prefixIcon: Icon(Icons.grain),
                ),
                items: _seedInterests.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedSeedInterest = val),
              ),
            ),
            const SizedBox(height: 16),

            AppCard(
              child: TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note_outlined),
                  hintText: 'Any observations about this lead...',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              label: _submitting ? 'Registering...' : 'Register Lead',
              icon: Icons.person_add,
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
