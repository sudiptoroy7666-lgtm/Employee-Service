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
import '../../../../core/utils/image_picker_service.dart';
import '../../domain/models/collection.dart';
import '../providers/collection_providers.dart';

class NewCollectionScreen extends ConsumerStatefulWidget {
  const NewCollectionScreen({super.key});

  @override
  ConsumerState<NewCollectionScreen> createState() => _NewCollectionScreenState();
}

class _NewCollectionScreenState extends ConsumerState<NewCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _referenceController = TextEditingController();
  Collection? _selectedInvoice;
  int _paymentMethodId = 96;
  final List<String> _imageUrls = [];
  final ImagePickerService _imagePicker = ImagePickerService();
  bool _submitting = false;

  static const _paymentMethods = [
    (id: 96, label: 'Cash'),
    (id: 97, label: 'Bank Transfer'),
    (id: 98, label: 'Mobile Banking (bKash/Nagad)'),
    (id: 99, label: 'Cheque'),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await _imagePicker.pickImage();
    if (path != null) {
      setState(() => _imageUrls.add(path));
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInvoice == null) {
      AppSnack.error(context, 'Please select an invoice to collect against.');
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;

    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Confirm Collection',
      confirmLabel: 'Record Payment',
      confirmIcon: Icons.attach_money,
      body: Column(
        children: [
          InfoRow(label: 'Client', value: _selectedInvoice!.clientName),
          const Divider(height: 18),
          InfoRow(label: 'Invoice', value: _selectedInvoice!.invoiceId),
          const Divider(height: 18),
          InfoRow(
            label: 'Due Amount',
            value: '৳${_selectedInvoice!.amount.toStringAsFixed(0)}',
            valueColor: AppColors.danger,
          ),
          const Divider(height: 18),
          InfoRow(
            label: 'Collecting',
            value: '৳${amount.toStringAsFixed(0)}',
            valueColor: AppColors.success,
          ),
          const Divider(height: 18),
          InfoRow(label: 'Method', value: _paymentMethods.firstWhere((m) => m.id == _paymentMethodId).label),
          const SizedBox(height: 8),
          Text(
            'This payment will be recorded against invoice ${_selectedInvoice!.invoiceId}.',
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
      final collection = Collection(
        id: '',
        invoiceId: _selectedInvoice!.invoiceId,
        clientName: _selectedInvoice!.clientName,
        amount: amount,
        collectionDate: DateTime.now(),
        paymentMethod: _paymentMethods.firstWhere((m) => m.id == _paymentMethodId).label,
        paymentMethodId: _paymentMethodId,
        referenceNumber: _referenceController.text.trim(),
        notes: _noteController.text.trim(),
        imageUrls: _imageUrls,
      );

      final repo = ref.watch(collectionRepositoryProvider);
      await repo.createCollection(collection);

      if (mounted) {
        AppSnack.success(context, 'Payment of ৳${amount.toStringAsFixed(0)} recorded successfully!');
        ref.invalidate(collectionsProvider);
        context.pop();
      }
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    } catch (e) {
      if (mounted) AppSnack.error(context, 'Failed to record payment. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collectionsAsync = ref.watch(collectionsProvider);

    return AppScaffold(
      title: 'Record Collection',
      body: collectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.invalidate(collectionsProvider),
        ),
        data: (invoices) {
          final dueInvoices = invoices.where((i) => i.amount > 0).toList();

          if (dueInvoices.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline,
              title: 'No pending collections',
              message: 'All invoices are fully paid. No collections needed.',
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(title: 'Select Invoice'),
                const SizedBox(height: 8),

                ...dueInvoices.map((invoice) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _InvoiceCard(
                    invoice: invoice,
                    isSelected: _selectedInvoice?.id == invoice.id,
                    onTap: () {
                      setState(() => _selectedInvoice = invoice);
                      _amountController.text = invoice.amount.toStringAsFixed(0);
                    },
                  ),
                )),

                if (_selectedInvoice != null) ...[
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Payment Details'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Collection Amount (BDT) *',
                            prefixIcon: const Icon(Icons.attach_money),
                            helperText: 'Due: ৳${_selectedInvoice!.amount.toStringAsFixed(0)}',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Amount is required';
                            final amount = double.tryParse(v);
                            if (amount == null) return 'Enter a valid amount';
                            if (amount <= 0) return 'Amount must be greater than 0';
                            if (amount > _selectedInvoice!.amount) {
                              return 'Cannot exceed due amount (৳${_selectedInvoice!.amount.toStringAsFixed(0)})';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _paymentMethodId,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method *',
                            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                          ),
                          items: _paymentMethods.map((m) {
                            return DropdownMenuItem(
                              value: m.id,
                              child: Text(m.label),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _paymentMethodId = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _referenceController,
                          decoration: const InputDecoration(
                            labelText: 'Reference No. (Optional)',
                            prefixIcon: Icon(Icons.receipt_outlined),
                            hintText: 'e.g., TXN-12345',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'Note (Optional)',
                            prefixIcon: Icon(Icons.note_outlined),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const SectionHeader(title: 'Payment Proof (Optional)'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Attach Photo'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        if (_imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${_imageUrls.length} photo(s) attached',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: _submitting ? 'Recording Payment...' : 'Record Payment',
                    icon: Icons.attach_money,
                    loading: _submitting,
                    onPressed: _submit,
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Collection invoice;
  final bool isSelected;
  final VoidCallback onTap;

  const _InvoiceCard({
    required this.invoice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      color: isSelected ? AppColors.infoBg : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.primary : AppColors.gray,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.clientName,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      '${invoice.orderNumber} • ${invoice.orderType.toUpperCase()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${invoice.amount.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total: ৳${invoice.totalAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
