import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/leave.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/states.dart';
import '../providers/leave_providers.dart';
import '../widgets/leave_request_card.dart';

class LeaveRequestsScreen extends ConsumerStatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  ConsumerState<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends ConsumerState<LeaveRequestsScreen> {
  LeaveStatus? _filter; // null = All

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(leaveRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new-leave',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/leave/new'),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('New Request', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: requestsAsync.when(
         loading: () => ListView(padding: const EdgeInsets.all(16), children: const [LoadingSkeleton(blocks: 3)]),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () => ref.read(leaveRequestsProvider.notifier).refresh(),
        ),
        data: (requests) {
          final filtered = _filter == null
              ? requests
              : requests.where((r) => r.status == _filter).toList();

          int countOf(LeaveStatus? s) =>
              s == null ? requests.length : requests.where((r) => r.status == s).length;

          return RefreshIndicator(
            onRefresh: () => ref.read(leaveRequestsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'All', count: countOf(null), selected: _filter == null, onTap: () => setState(() => _filter = null)),
                      _FilterChip(label: 'Pending', count: countOf(LeaveStatus.pending), selected: _filter == LeaveStatus.pending, onTap: () => setState(() => _filter = LeaveStatus.pending)),
                      _FilterChip(label: 'Approved', count: countOf(LeaveStatus.approved), selected: _filter == LeaveStatus.approved, onTap: () => setState(() => _filter = LeaveStatus.approved)),
                      _FilterChip(label: 'Rejected', count: countOf(LeaveStatus.rejected), selected: _filter == LeaveStatus.rejected, onTap: () => setState(() => _filter = LeaveStatus.rejected)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  EmptyStateWidget(
                    icon: Icons.beach_access,
                    title: _filter == null ? 'No leave requests yet' : 'No ${_filter!.label.toLowerCase()} requests',
                    message: _filter == null
                        ? 'When you request time off, it will appear here with its approval status.'
                        : 'Nothing here right now. Try a different filter.',
                    actionLabel: _filter == null ? 'Request Leave' : null,
                    onAction: _filter == null ? () => context.push('/leave/new') : null,
                  )
                else
                  ...List.generate(filtered.length, (i) {
                    final request = filtered[i];
                    return Reveal(
                      delay: Duration(milliseconds: i * 50),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LeaveRequestCard(
                          request: request,
                          onTap: () => context.push('/leave/detail/${request.id}'),
                        ),
                      ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.count, required this.selected, required this.onTap});
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.primary : theme.dividerColor),
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