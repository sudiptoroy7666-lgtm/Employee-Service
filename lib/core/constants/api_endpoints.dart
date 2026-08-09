/// Central map of every backend API path used by the app.
///
/// Feature repositories must reference these constants instead of hardcoding
/// path strings, so a single change keeps every caller in sync.
class ApiEndpoints {
  ApiEndpoints._();

  // ---- Auth ----
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String refresh = '/api/auth/refresh';

  // ---- Employee / Profile ----
  static const String me = '/api/employees/me';
  static const String employees = '/api/employees/';

  // ---- Attendance ----
  static const String attendanceReport = '/api/attendance/report';
  static const String attendanceToday = '/api/attendance/attendance/today';
  static const String checkIn = '/api/attendance/check-in';
  static const String checkOut = '/api/attendance/check-out';

  // ---- Leave ----
  static const String leaveRequests = '/api/leave-requests/';
  static const String leaveBalance = '/api/leave-requests/leave-balance';

  // ---- Payments ----
  static const String payments = '/api/payments';
  static const String payroll = '/api/payroll/';

  // ---- Statement ----
  static const String statements = '/api/statements';


}