import '../models/followup.dart';

abstract class FollowUpRepository {
  Future<List<FollowUp>> getFollowUps({String? leadId, int? outcomeId});
  Future<FollowUp> createFollowUp(FollowUp followUp);
}
