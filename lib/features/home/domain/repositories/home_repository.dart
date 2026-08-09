import '../../../../core/models/activity.dart';
import '../../../../core/models/employee.dart';

/// Aggregates the data the Home screen renders on load: the employee's
/// profile and today's recent activity. Backed by [RemoteHomeRepository].
abstract class HomeRepository {
  Future<Employee> getProfile();
  Future<List<ActivityItem>> getRecentActivities();
}