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
import '../../../visits/domain/services/client_product_permission_service.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_item.dart';
import '../../domain/models/order_status.dart';
import '../../domain/models/product.dart';
import '../providers/order_providers.dart';

class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  MarketingClient? _selectedStakeholder;
  final List<_OrderItemDraft> _items = [];
  final _noteController = TextEditingController();
  final _paidAmountController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_OrderItemDraft());
    });
  }

  double _calculateTotal() {
    return _items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  }

  Future<void> _submitOrder() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStakeholder == null) {
      AppSnack.error(context, 'Please select a dealer/client first.');
      return;
    }
    if (_items.isEmpty) {
      AppSnack.error(context, 'Please add at least one item.');
      return;
    }

    for (final item in _items) {
      if (item.productId == null) {
        AppSnack.error(context, 'Please select a product for every item.');
        return;
      }
    }

    final total = _calculateTotal();
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;

    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Confirm Order',
      confirmLabel: 'Book Order',
      confirmIcon: Icons.shopping_cart,
      body: Column(
        children: [
          InfoRow(label: 'Client', value: _selectedStakeholder!.displayName),
          const Divider(height: 18),
          InfoRow(label: 'Client Type', value: _selectedStakeholder!.typeLabel),
          const Divider(height: 18),
          InfoRow(label: 'Total Items', value: '${_items.length}'),
          const Divider(height: 18),
          InfoRow(
            label: 'Total Amount',
            value: '৳${total.toStringAsFixed(0)}',
            valueColor: AppColors.primary,
          ),
          if (paidAmount > 0) ...[
            const Divider(height: 18),
            InfoRow(
              label: 'Paid Now',
              value: '৳${paidAmount.toStringAsFixed(0)}',
              valueColor: AppColors.success,
            ),
            const Divider(height: 18),
            InfoRow(
              label: 'Due',
              value: '৳${(total - paidAmount).toStringAsFixed(0)}',
              valueColor: AppColors.danger,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'This order will be booked on behalf of ${_selectedStakeholder!.displayName}.',
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
      final order = Order(
        id: '',
        orderNumber: '',
        clientId: _selectedStakeholder!.id,
        clientName: _selectedStakeholder!.displayName,
        orderDate: DateTime.now(),
        deliveryDate: DateTime.now().add(const Duration(days: 7)),
        status: OrderStatus.pending,
        totalAmount: total,
        items: _items.map((draft) => OrderItem(
          id: draft.productId ?? '', // FIX: Pass the actual product ID
          productName: draft.productName,
          quantity: draft.quantity,
          unitPrice: draft.unitPrice,
          totalPrice: draft.quantity * draft.unitPrice,
        )).toList(),
        supervisorName: '',
        notes: _noteController.text.trim(),
      );

      await ref.read(createOrderProvider.notifier).submit(order);

      if (mounted) {
        AppSnack.success(context, 'Order booked successfully for ${_selectedStakeholder!.displayName}!');
        context.pop();
      }
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    } catch (e) {
      if (mounted) AppSnack.error(context, 'Failed to book order. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stakeholdersAsync = ref.watch(stakeholdersProvider);
    final productsAsync = ref.watch(productsProvider);
    final permissionService = ClientProductPermissionService();

    return AppScaffold(
      title: 'Book Order for Client',
      body: stakeholdersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.invalidate(stakeholdersProvider),
        ),
        data: (stakeholders) => productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorStateWidget(
            error: e,
            onRetry: () => ref.invalidate(productsProvider),
          ),
          data: (products) => _buildForm(
            context,
            stakeholders,
            products,
            permissionService,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<MarketingClient> stakeholders,
    List<Product> products,
    ClientProductPermissionService permissionService,
  ) {
    final theme = Theme.of(context);
    debugPrint('📦 Products loaded: ${products.length}');
    for (final p in products) {
      debugPrint('  - ${p.name} (id: ${p.id}, price: ${p.price})');
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
                AppCard(
                  color: AppColors.infoBg,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You are booking an order ON BEHALF OF a dealer/client. Select the client first.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<MarketingClient>(
                  value: _selectedStakeholder,
                  decoration: const InputDecoration(
                    labelText: 'Select Dealer / Client *',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  items: stakeholders.where((s) => s.isActive).map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(
                        '${s.displayName} (${s.typeLabel})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedStakeholder = val;
                      _items.clear();
                    });
                  },
                  validator: (v) => v == null ? 'Please select a client' : null,
                ),
                const SizedBox(height: 8),

                if (_selectedStakeholder != null) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.store, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              _selectedStakeholder!.displayName,
                              style: theme.textTheme.titleSmall,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.infoBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _selectedStakeholder!.typeLabel,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contact: ${_selectedStakeholder!.contact}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_selectedStakeholder!.address != null)
                          Text(
                            'Address: ${_selectedStakeholder!.address}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _selectedStakeholder!.bulkOrderAllowed
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 14,
                              color: _selectedStakeholder!.bulkOrderAllowed
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedStakeholder!.bulkOrderAllowed
                                  ? 'Bulk orders allowed'
                                  : 'Bulk orders NOT allowed',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _selectedStakeholder!.bulkOrderAllowed
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (permissionService.filterAllowedProducts(
                    client: _selectedStakeholder!,
                    products: products,
                  ).isEmpty) ...[
                    const SizedBox(height: 8),
                    AppCard(
                      color: AppColors.warningBg,
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No products available in inventory. Please contact the warehouse team.',
                              style: TextStyle(color: AppColors.warning, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SectionHeader(title: 'Order Items'),
                  const SizedBox(height: 8),

                  if (_items.isEmpty)
                    AppCard(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Tap "Add Item" to add products to this order.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),

                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final allowedProducts = permissionService.filterAllowedProducts(
                      client: _selectedStakeholder!,
                      products: products,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OrderItemRow(
                        item: item,
                        products: allowedProducts,
                        onRemove: () => setState(() => _items.removeAt(index)),
                        onChanged: (updatedItem) {
                          setState(() {
                            _items[index] = updatedItem;
                          });
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                  if (permissionService.filterAllowedProducts(
                    client: _selectedStakeholder!,
                    products: products,
                  ).length < products.length) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Some products are hidden because this client does not have bulk order permission.',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  const SectionHeader(title: 'Payment Details'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _paidAmountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount Paid Now (BDT)',
                            prefixIcon: Icon(Icons.payments_outlined),
                            hintText: '0',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method',
                            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'cash', child: Text('Cash')),
                            DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                            DropdownMenuItem(value: 'mobile', child: Text('Mobile Banking (bKash/Nagad)')),
                            DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                            DropdownMenuItem(value: 'credit', child: Text('Credit (Due)')),
                          ],
                          onChanged: (val) => setState(() => _paymentMethod = val ?? 'cash'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  AppCard(
                    child: TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Order Note (Optional)',
                        prefixIcon: Icon(Icons.note_outlined),
                        hintText: 'e.g., Urgent delivery required',
                      ),
                      maxLines: 2,
                    ),
                  ),

                  const SizedBox(height: 24),

                  AppCard(
                    color: AppColors.grayBg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: theme.textTheme.titleMedium),
                        Text(
                          '৳${_calculateTotal().toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: _submitting ? 'Booking Order...' : 'Book Order',
                    icon: Icons.shopping_cart,
                    loading: _submitting,
                    onPressed: _submitOrder,
                  ),
                ] else ...[
                  const SizedBox(height: 24),
                  AppCard(
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.store_outlined, size: 48, color: AppColors.gray),
                            SizedBox(height: 12),
                            Text(
                              'Select a dealer/client above to start booking an order.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
        );
  }
}

class _OrderItemDraft {
  String? productId;
  String productName = '';
  int quantity = 1;
  double unitPrice = 0;

  _OrderItemDraft copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
  }) {
    return _OrderItemDraft()
      ..productId = productId ?? this.productId
      ..productName = productName ?? this.productName
      ..quantity = quantity ?? this.quantity
      ..unitPrice = unitPrice ?? this.unitPrice;
  }
}

class _OrderItemRow extends StatefulWidget {
  final _OrderItemDraft item;
  final List<Product> products;
  final VoidCallback onRemove;
  final ValueChanged<_OrderItemDraft> onChanged;

  const _OrderItemRow({
    required this.item,
    required this.products,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_OrderItemRow> createState() => _OrderItemRowState();
}

class _OrderItemRowState extends State<_OrderItemRow> {
  late String? _selectedProductId;
  late int _quantity;
  late double _unitPrice;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.item.productId;
    _quantity = widget.item.quantity;
    _unitPrice = widget.item.unitPrice;
  }

  @override
  void didUpdateWidget(covariant _OrderItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _selectedProductId = widget.item.productId;
      _quantity = widget.item.quantity;
      _unitPrice = widget.item.unitPrice;
    }
  }

  void _onProductChanged(String? value) {
    setState(() {
      _selectedProductId = value;
      if (value != null) {
        final product = widget.products.firstWhere((p) => p.id == value);
        widget.item.productId = value;
        widget.item.productName = product.name;
        widget.item.unitPrice = product.price;
        _unitPrice = product.price;
        widget.onChanged(widget.item);
      }
    });
  }

  void _onQuantityChanged(String value) {
    setState(() {
      _quantity = int.tryParse(value) ?? 1;
      widget.item.quantity = _quantity;
      widget.onChanged(widget.item);
    });
  }

  void _onPriceChanged(String value) {
    setState(() {
      _unitPrice = double.tryParse(value) ?? 0;
      widget.item.unitPrice = _unitPrice;
      widget.onChanged(widget.item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedProductId,
                  decoration: const InputDecoration(
                    labelText: 'Product',
                    hintText: 'Select product',
                    isDense: true,
                  ),
                  items: widget.products.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        '${p.name} (৳${p.price.toStringAsFixed(0)}/${p.unit})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _onProductChanged,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _quantity.toString(),
                  onChanged: _onQuantityChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Unit Price (BDT)',
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  initialValue: _unitPrice.toString(),
                  onChanged: _onPriceChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Subtotal',
                    isDense: true,
                  ),
                  child: Text(
                    '৳${(_quantity * _unitPrice).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
