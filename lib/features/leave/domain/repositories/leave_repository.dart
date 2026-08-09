import '../../../../core/models/leave.dart';

abstract class LeaveRepository {
  Future<List<LeaveRequest>> getRequests();
  Future<LeaveRequest?> getRequestById(String id);
  Future<LeaveRequest> submitRequest(NewLeaveRequest request);
  Future<List<LeaveBalance>> getBalances();
}