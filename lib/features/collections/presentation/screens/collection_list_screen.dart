import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/states.dart';
import '../providers/collection_providers.dart';

class CollectionListScreen extends ConsumerWidget {
  const CollectionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/collections/new'),
        icon: const Icon(Icons.attach_money),
        label: const Text('Record Payment'),
      ),
      body: collectionsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [LoadingSkeleton(blocks: 4)],
        ),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.invalidate(collectionsProvider),
        ),
        data: (collections) {
          if (collections.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.attach_money_outlined,
              title: 'No collections yet',
              message: 'Record your first collection to see it here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(collectionsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.attach_money, size: 20, color: AppColors.success),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(collection.clientName, style: Theme.of(context).textTheme.titleSmall),
                                Text(
                                  Fmt.dateMedium(collection.collectionDate),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '৳${collection.amount.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            collection.paymentMethod,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            collection.referenceNumber,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
