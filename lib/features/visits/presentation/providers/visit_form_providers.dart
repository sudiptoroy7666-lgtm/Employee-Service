import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../leads/domain/models/lead.dart';
import '../../../leads/presentation/providers/lead_providers.dart';
import '../../../followups/domain/models/followup.dart';
import '../../../followups/presentation/providers/followup_providers.dart';
import '../../domain/models/visit.dart';
import '../../domain/models/visit_type.dart';
import '../../domain/models/visit_status.dart';
import '../../domain/models/client.dart';
import 'visit_providers.dart';

final selectedClientIdProvider = StateProvider<String?>((ref) => null);
final selectedVisitTypeProvider = StateProvider<VisitType?>((ref) => null);
final visitNotesProvider = StateProvider<String>((ref) => '');
final selectedVisitProductIdsProvider = StateProvider<List<String>>((ref) => []);
final visitEstimatedDemandProvider = StateProvider<String>((ref) => '');

final createVisitControllerProvider = StateNotifierProvider<CreateVisitController, AsyncValue<Visit?>>(
  (ref) => CreateVisitController(ref),
);

class CreateVisitController extends StateNotifier<AsyncValue<Visit?>> {
  final Ref _ref;

  CreateVisitController(this._ref) : super(const AsyncData(null));

  Future<void> submit({
    required String clientName,
    required String clientId,
    required ClientType clientType,
  }) async {
    state = const AsyncLoading();
    try {
      final visitType = _ref.read(selectedVisitTypeProvider);
      final notes = _ref.read(visitNotesProvider);
      final productIds = _ref.read(selectedVisitProductIdsProvider);
      final demand = _ref.read(visitEstimatedDemandProvider);

      if (visitType == null) {
        throw const AppFailure('Please select a visit type.');
      }

      switch (visitType) {
        case VisitType.newLead:
          await _submitAsLead(clientName: clientName, notes: notes);
          break;

        case VisitType.followUp:
          await _submitAsFollowUp(leadId: clientId, notes: notes);
          break;

        default:
          await _submitAsVisit(
            clientName: clientName,
            clientId: clientId,
            clientType: clientType,
            visitType: visitType,
            notes: notes,
            productIds: productIds,
            demand: demand,
          );
      }

      state = const AsyncData(null);
      _ref.invalidate(visitsProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> _submitAsLead({
    required String clientName,
    required String notes,
  }) async {
    final leadRepo = _ref.read(leadRepositoryProvider);
    await leadRepo.createLead(
      Lead(
        id: '',
        name: clientName,
        contact: '',
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  Future<void> _submitAsFollowUp({
    required String leadId,
    required String notes,
  }) async {
    final followUpRepo = _ref.read(followUpRepositoryProvider);
    await followUpRepo.createFollowUp(
      FollowUp(
        id: '',
        leadId: leadId,
        followUpDate: DateTime.now(),
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  Future<void> _submitAsVisit({
    required String clientName,
    required String clientId,
    required ClientType clientType,
    required VisitType visitType,
    required String notes,
    required List<String> productIds,
    required String demand,
  }) async {
    final locationService = _ref.read(locationServiceProvider);

    // GPS is MANDATORY for visit creation
    final loc = await locationService.getVisitLocation(requireGps: true);
    final visitLocation = VisitLocation(
      latitude: loc['latitude']!,
      longitude: loc['longitude']!,
      address: 'Current Location',
    );

    final visit = Visit(
      id: '',
      clientName: clientName,
      clientId: clientId,
      clientType: clientType,
      visitType: visitType,
      scheduledTime: DateTime.now(),
      status: VisitStatus.pending,
      notes: notes,
      location: visitLocation,
      productIds: productIds,
      estimatedDemand: demand.isEmpty ? null : demand,
    );

    final repo = _ref.read(visitRepositoryProvider);

    // FIX: Get the logged-in employee's ID to send as assignedToId
    final employee = _ref.read(authControllerProvider).valueOrNull;
    final assignedToId = employee?.id;

    try {
      await repo.createVisit(visit, assignedToId: assignedToId);
    } on AppFailure catch (e) {
      debugPrint('❌ Visit creation AppFailure: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Visit creation unexpected error: $e');
      throw AppFailure('Failed to create visit: ${e.toString()}');
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
