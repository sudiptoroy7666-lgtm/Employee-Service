import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/states.dart';
import '../providers/promotion_providers.dart';

class PromotionListScreen extends ConsumerWidget {
  const PromotionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(promotionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Promotions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/promotions/new'),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: promotionsAsync.when(
        loading: () => ListView(padding: const EdgeInsets.all(16), children: const [LoadingSkeleton(blocks: 4)]),
        error: (e, _) => ErrorStateWidget(error: e, onRetry: () => ref.invalidate(promotionsProvider)),
        data: (promotions) {
          if (promotions.isEmpty) {
            return const EmptyStateWidget(icon: Icons.campaign_outlined, title: 'No active promotions');
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(promotionsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final p = promotions[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.campaign, size: 20, color: AppColors.primary)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(p.productName, style: Theme.of(context).textTheme.titleSmall)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Estimated Demand: ${p.estimatedDemand}', style: Theme.of(context).textTheme.bodyMedium),
                      if (p.competitorProductName != null) ...[
                        const SizedBox(height: 4),
                        Text('Competitor: ${p.competitorProductName}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      ],
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
