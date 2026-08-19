import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../orders/domain/models/product.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../domain/models/marketing_client.dart';
import '../../domain/models/visit_type.dart';
import '../../domain/services/client_product_permission_service.dart';
import '../providers/client_providers.dart';
import '../providers/visit_form_providers.dart';

class NewVisitScreen extends ConsumerStatefulWidget {
  const NewVisitScreen({super.key});

  @override
  ConsumerState<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends ConsumerState<NewVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  MarketingClient? _selectedClient;

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final productsAsync = ref.watch(productsProvider);
    final visitType = ref.watch(selectedVisitTypeProvider);
    final permissionService = ref.watch(clientProductPermissionServiceProvider);

    return AppScaffold(
      title: 'New Visit',
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading clients')),
        data: (clients) {
          return productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading products')),
            data: (products) {
              return _buildForm(context, clients, products, visitType, permissionService);
            },
          );
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<MarketingClient> clients,
    List<Product> products,
    VisitType? visitType,
    ClientProductPermissionService permissionService,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Client Selector
          AppCard(
            child: DropdownButtonFormField<MarketingClient>(
              value: _selectedClient,
              decoration: const InputDecoration(
                labelText: 'Select Client',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: clients.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text('${c.name} (${c.type.label})'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedClient = val);
                ref.read(selectedClientIdProvider.notifier).state = val?.id;
                // Reset products when client changes
                ref.read(selectedVisitProductIdsProvider.notifier).state = [];
              },
              validator: (v) => v == null ? 'Please select a client' : null,
            ),
          ),
          const SizedBox(height: 16),

          // Visit Type
          AppCard(
            child: DropdownButtonFormField<VisitType>(
              value: visitType,
              decoration: const InputDecoration(
                labelText: 'Visit Type',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: VisitType.values.map((t) {
                return DropdownMenuItem(value: t, child: Text(t.label));
              }).toList(),
              onChanged: (val) => ref.read(selectedVisitTypeProvider.notifier).state = val,
              validator: (v) => v == null ? 'Please select a visit type' : null,
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          AppCard(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onChanged: (val) => ref.read(visitNotesProvider.notifier).state = val,
            ),
          ),
          const SizedBox(height: 16),

          // Conditional: Promotion Fields
          if (visitType == VisitType.promotion) ...[
            SectionHeader(title: 'Promotion Details'),
            const SizedBox(height: 8),
            
            // Product Selector
            if (_selectedClient != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Products', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: permissionService
                          .filterAllowedProducts(client: _selectedClient!, products: products)
                          .map((p) => _ProductChip(
                                product: p,
                                isSelected: ref.watch(selectedVisitProductIdsProvider).contains(p.id),
                                onToggle: (selected) {
                                  final current = ref.read(selectedVisitProductIdsProvider);
                                  if (selected) {
                                    ref.read(selectedVisitProductIdsProvider.notifier).state = [...current, p.id];
                                  } else {
                                    ref.read(selectedVisitProductIdsProvider.notifier).state = current.where((id) => id != p.id).toList();
                                  }
                                },
                              ))
                          .toList(),
                    ),
                    if (permissionService.filterAllowedProducts(client: _selectedClient!, products: products).isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'No allowed products for this client.',
                          style: TextStyle(color: AppColors.warning, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Estimated Demand
            AppCard(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Estimated Demand',
                  prefixIcon: Icon(Icons.trending_up),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => ref.read(visitEstimatedDemandProvider.notifier).state = val,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required for promotion';
                  if (int.tryParse(v) == null) return 'Must be a number';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Location Preview (Read Only)
          AppCard(
            color: AppColors.infoBg,
            child: Row(
              children: [
                const Icon(Icons.gps_fixed, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'GPS Location will be captured automatically on submit.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Create Visit',
            onPressed: () => _submit(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) return;

    final visitType = ref.read(selectedVisitTypeProvider);
    if (visitType == VisitType.promotion) {
      final products = ref.read(selectedVisitProductIdsProvider);
      if (products.isEmpty) {
        AppSnack.error(context, 'Please select at least one product for promotion.');
        return;
      }
    }

    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Confirm Visit',
      confirmLabel: 'Create',
      body: Text('Create a ${visitType!.label} visit for ${_selectedClient!.name}?'),
    );

    if (!confirmed || !mounted) return;

    try {
      await ref.read(createVisitControllerProvider.notifier).submit(
            clientName: _selectedClient!.name,
            clientId: _selectedClient!.id,
            clientType: _selectedClient!.type,
          );
      if (mounted) {
        AppSnack.success(context, 'Visit created successfully.');
        context.pop();
      }
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    } catch (e) {
      if (mounted) AppSnack.error(context, 'Failed to create visit.');
    }
  }
}

class _ProductChip extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final ValueChanged<bool> onToggle;

  const _ProductChip({required this.product, required this.isSelected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grayBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          product.name,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
