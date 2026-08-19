import '../models/visit.dart';

abstract class VisitRepository {
  Future<List<Visit>> getVisits({
    String? userId,
    int? typeId,
    int? statusId,
    String? startDate,
    String? endDate,
  });

  Future<Visit?> getVisitById(String id);

  /// Creates a visit.
  /// [assignedToId] is the ID of the logged-in employee (required by backend).
  Future<Visit> createVisit(Visit visit, {String? assignedToId});

  Future<Visit> checkInVisit(String visitId);

  Future<Visit> checkOutVisit(String visitId, {String? notes, List<String>? imagePaths});

  Future<Visit> cancelVisit(String visitId);
}