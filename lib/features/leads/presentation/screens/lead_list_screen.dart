import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/states.dart';
import '../../domain/models/lead.dart';
import '../providers/lead_providers.dart';

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});

  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen> {
  LeadStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Leads')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/leads/new'),
        icon: const Icon(Icons.person_add),
        label: const Text('New Lead'),
      ),
      body: leadsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [LoadingSkeleton(blocks: 4)],
        ),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.invalidate(leadsProvider),
        ),
        data: (leads) {
          final filtered = _filter == null
              ? leads
              : leads.where((l) => l.status == _filter).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(leadsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        count: leads.length,
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      for (final status in LeadStatus.values)
                        _FilterChip(
                          label: status.label,
                          count: leads.where((l) => l.status == status).length,
                          selected: _filter == status,
                          onTap: () => setState(() => _filter = status),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (filtered.isEmpty)
                  EmptyStateWidget(
                    icon: Icons.person_add_outlined,
                    title: _filter == null ? 'No leads yet' : 'No ${_filter!.label.toLowerCase()} leads',
                    message: _filter == null
                        ? 'Register your first lead during a field visit.'
                        : 'Try a different filter.',
                    actionLabel: _filter == null ? 'Register Lead' : null,
                    onAction: _filter == null ? () => context.push('/leads/new') : null,
                  )
                else
                  ...List.generate(filtered.length, (i) {
                    final lead = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LeadCard(lead: lead),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final Lead lead;

  const _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusColor, statusBg) = switch (lead.status) {
      LeadStatus.newLead => (AppColors.primary, AppColors.infoBg),
      LeadStatus.contacted => (AppColors.warning, AppColors.warningBg),
      LeadStatus.qualified => (AppColors.success, AppColors.successBg),
      LeadStatus.converted => (AppColors.success, AppColors.successBg),
      LeadStatus.lost => (AppColors.danger, AppColors.dangerBg),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.person_add, size: 20, color: AppColors.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${lead.contact}${lead.company != null ? ' • ${lead.company}' : ''}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  lead.status.label,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (lead.notes != null && lead.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              lead.notes!,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 12, color: AppColors.gray),
              const SizedBox(width: 4),
              Text(
                Fmt.dateMedium(lead.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(color: AppColors.gray),
              ),
              if (lead.seedInterestName != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.grayBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    lead.seedInterestName!,
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.22) : AppColors.grayBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
