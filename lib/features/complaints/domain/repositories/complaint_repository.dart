import '../models/complaint.dart';

abstract class ComplaintRepository {
  Future<List<Complaint>> getComplaints();
  Future<Complaint> createComplaint(Complaint complaint);
}
