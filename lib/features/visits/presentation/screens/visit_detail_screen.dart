import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/utils/image_picker_service.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';
import '../../../../core/widgets/sheets.dart';
import '../../../../core/widgets/states.dart';
import '../../domain/models/visit_status.dart';
import '../providers/visit_detail_providers.dart';

class VisitDetailScreen extends ConsumerStatefulWidget {
  final String visitId;
  const VisitDetailScreen({super.key, required this.visitId});

  @override
  ConsumerState<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends ConsumerState<VisitDetailScreen> {
  final _notesController = TextEditingController();
  final List<String> _imagePaths = [];
  final ImagePickerService _imagePicker = ImagePickerService();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitAsync = ref.watch(visitDetailProvider(widget.visitId));
    final checkInState = ref.watch(visitCheckInControllerProvider);
    final checkOutState = ref.watch(visitCheckOutControllerProvider);
    final isLoading = checkInState.isLoading || checkOutState.isLoading;

    return AppScaffold(
      title: 'Visit Detail',
      body: visitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(error: e),
        data: (visit) {
          _notesController.text = visit.notes;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(visit.clientName, style: Theme.of(context).textTheme.headlineSmall),
                              Text('${visit.clientType.label} • ${visit.visitType.label}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        _VisitStatusChip(status: visit.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Scheduled: ${Fmt.dateFull(visit.scheduledTime)} at ${Fmt.time(visit.scheduledTime)}', style: Theme.of(context).textTheme.bodySmall),
                    if (visit.isLocalOnly)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Pending Sync', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info
              if (visit.notes.isNotEmpty || visit.estimatedDemand != null || visit.productIds.isNotEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (visit.notes.isNotEmpty) ...[
                        Text('Notes', style: Theme.of(context).textTheme.titleSmall),
                        Text(visit.notes),
                        const SizedBox(height: 8),
                      ],
                      if (visit.estimatedDemand != null) ...[
                        Text('Estimated Demand: ${visit.estimatedDemand}', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                      ],
                      if (visit.productIds.isNotEmpty) ...[
                        Text('Products: ${visit.productIds.length} selected', style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Timeline
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Timeline', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _TimelineItem(label: 'Created', time: visit.scheduledTime, icon: Icons.add_circle, color: AppColors.primary),
                    if (visit.checkInTime != null)
                      _TimelineItem(label: 'Checked In', time: visit.checkInTime!, icon: Icons.login, color: AppColors.success),
                    if (visit.checkOutTime != null)
                      _TimelineItem(label: 'Checked Out', time: visit.checkOutTime!, icon: Icons.logout, color: AppColors.navy),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              if (visit.status == VisitStatus.pending)
                PrimaryButton(
                  label: isLoading ? 'Checking In...' : 'Check In',
                  icon: Icons.login,
                  loading: isLoading,
                  onPressed: () => _confirmCheckIn(context, visit.id),
                )
              else if (visit.status == VisitStatus.checkedIn)
                PrimaryButton(
                  label: isLoading ? 'Checking Out...' : 'Check Out',
                  icon: Icons.logout,
                  loading: isLoading,
                  onPressed: () => _showCheckOutSheet(context, visit.id),
                ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmCheckIn(BuildContext context, String visitId) async {
    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: 'Check In',
      confirmLabel: 'Check In',
      body: const Text('Confirm check-in at current location?'),
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(visitCheckInControllerProvider.notifier).checkIn(visitId);
      if (mounted) AppSnack.success(context, 'Checked in successfully.');
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    }
  }

  Future<void> _showCheckOutSheet(BuildContext context, String visitId) async {
    _notesController.clear();
    _imagePaths.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Check Out', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Add Notes (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Attach Photo (Optional)'),
                onPressed: () async {
                  final path = await _imagePicker.pickImage();
                  if (path != null) {
                    setModalState(() => _imagePaths.add(path));
                  }
                },
              ),
              if (_imagePaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${_imagePaths.length} photo(s) attached', style: TextStyle(color: AppColors.success)),
                ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Confirm Check Out',
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _performCheckOut(context, visitId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performCheckOut(BuildContext context, String visitId) async {
    try {
      await ref.read(visitCheckOutControllerProvider.notifier).checkOut(
            visitId,
            notes: _notesController.text,
            imagePaths: _imagePaths,
          );
      if (mounted) AppSnack.success(context, 'Checked out successfully.');
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    }
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final DateTime time;
  final IconData icon;
  final Color color;

  const _TimelineItem({required this.label, required this.time, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          Text('${Fmt.dateShort(time)} ${Fmt.time(time)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _VisitStatusChip extends StatelessWidget {
  final VisitStatus status;
  const _VisitStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      VisitStatus.pending => (AppColors.warning, AppColors.warningBg),
      VisitStatus.checkedIn => (AppColors.primary, AppColors.infoBg),
      VisitStatus.completed => (AppColors.success, AppColors.successBg),
      VisitStatus.cancelled => (AppColors.danger, AppColors.dangerBg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
