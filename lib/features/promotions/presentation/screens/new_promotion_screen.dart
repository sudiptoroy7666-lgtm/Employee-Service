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
import '../providers/promotion_form_providers.dart';
import '../providers/promotion_providers.dart';

class NewPromotionScreen extends ConsumerStatefulWidget {
  const NewPromotionScreen({super.key});

  @override
  ConsumerState<NewPromotionScreen> createState() => _NewPromotionScreenState();
}

class _NewPromotionScreenState extends ConsumerState<NewPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(promotionProductsProvider);

    return AppScaffold(
      title: 'New Promotion',
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading products')),
        data: (products) => _buildForm(context, products),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<Product> products) {
    debugPrint('📦 Promotion products loaded: ${products.length}');

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Product Selection
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Product', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                if (products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No products available. Check inventory or contact warehouse.',
                            style: TextStyle(color: AppColors.warning, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<Product>(
                    value: _selectedProduct,
                    decoration: const InputDecoration(
                      labelText: 'Seed Product *',
                      prefixIcon: Icon(Icons.grain),
                      hintText: 'Select a product',
                    ),
                    items: products.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(
                          '${p.name} (৳${p.price.toStringAsFixed(0)}/${p.unit})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedProduct = val);
                      ref.read(selectedProductIdProvider.notifier).state = val?.id;
                    },
                    validator: (v) => v == null ? 'Please select a product' : null,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Estimated Demand
          AppCard(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Estimated Demand (kg) *',
                prefixIcon: Icon(Icons.trending_up),
                hintText: 'e.g., 500',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => ref.read(estimatedDemandProvider.notifier).state = v,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Estimated demand is required';
                if (int.tryParse(v) == null) return 'Must be a number';
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Competitor Info
          const SectionHeader(title: 'Competitor Info (Optional)'),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Competitor Product Name',
                    prefixIcon: Icon(Icons.compare_arrows),
                  ),
                  onChanged: (v) => ref.read(competitorNameProvider.notifier).state = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Competitor Price (BDT/kg)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => ref.read(competitorPriceProvider.notifier).state = v,
                  validator: (v) {
                    if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                      return 'Must be a number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Competitor Notes',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                  maxLines: 2,
                  onChanged: (v) => ref.read(competitorNotesProvider.notifier).state = v,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Save Market Update',
            icon: Icons.campaign,
            onPressed: () => _submit(context),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) return;

    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Confirm Promotion',
      confirmLabel: 'Save',
      body: Text('Save promotion for ${_selectedProduct!.name}?'),
    );

    if (!confirmed || !mounted) return;

    try {
      await ref.read(createPromotionControllerProvider.notifier).submit(productName: _selectedProduct!.name);
      if (mounted) {
        AppSnack.success(context, 'Promotion saved.');
        context.pop();
      }
    } on AppFailure catch (e) {
  if (mounted) AppSnack.error(context, e.message);
  } catch (e) {
  // FIX: Catch generic DioExceptions so the user sees the error
  if (mounted) AppSnack.error(context, 'Failed: ${e.toString()}');
  }
  }
}
