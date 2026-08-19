import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/states.dart';
import '../providers/order_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return AppScaffold(
      title: 'Order Detail',
      body: orderAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [LoadingSkeleton(blocks: 3)],
        ),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
        data: (order) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Reveal(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.orderNumber, style: Theme.of(context).textTheme.headlineSmall),
                                const SizedBox(height: 4),
                                Text(
                                  'Placed on ${Fmt.dateFull(order.orderDate)}',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatusBadge(status: order.status.label),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: const Duration(milliseconds: 80),
                child: AppCard(
                  child: Column(
                    children: [
                      InfoRow(label: 'Client', value: order.clientName),
                      const Divider(height: 18),
                      InfoRow(label: 'Supervisor', value: order.supervisorName),
                      const Divider(height: 18),
                      InfoRow(label: 'Delivery Date', value: Fmt.dateMedium(order.deliveryDate)),
                      const Divider(height: 18),
                      InfoRow(label: 'Total Items', value: '${order.totalItems}'),
                      const Divider(height: 18),
                      InfoRow(
                        label: 'Total Amount',
                        value: '৳${order.totalAmount.toStringAsFixed(2)}',
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: const Duration(milliseconds: 160),
                child: const SectionHeader(title: 'Order Items'),
              ),
              ...order.items.map((item) => AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: Theme.of(context).textTheme.titleSmall),
                          Text(
                            '${item.quantity} × ৳${item.unitPrice.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '৳${item.totalPrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
              if (order.notes.isNotEmpty) ...[
                const SizedBox(height: 14),
                Reveal(
                  delay: const Duration(milliseconds: 240),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(order.notes, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
