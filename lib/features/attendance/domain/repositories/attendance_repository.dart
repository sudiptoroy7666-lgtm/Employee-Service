import '../../../../core/models/attendance.dart';
import '../../../../core/models/check_in_out.dart';

abstract class AttendanceRepository {
  Future<MonthAttendance> getMonthAttendance(DateTime month);
  Future<AttendanceRecord?> getRecordById(String id);
  Future<CheckInOutRecord> getToday();
  Future<CheckInOutRecord> checkIn();
  Future<CheckInOutRecord> checkOut();
}