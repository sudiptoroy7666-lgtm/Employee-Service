import '../models/lead.dart';

abstract class LeadRepository {
  Future<List<Lead>> getLeads({int? statusId, int? sourceId, String? search});
  Future<Lead> createLead(Lead lead);
  Future<Lead> updateLead(Lead lead);
}
