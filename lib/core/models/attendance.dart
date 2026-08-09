enum AttendanceStatus { present, late, absent, holiday, weekend }

extension AttendanceStatusLabel on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.holiday:
        return 'Holiday';
      case AttendanceStatus.weekend:
        return 'Weekend';
    }
  }
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.totalWorkingMinutes = 0,
    this.lateMinutes = 0,
    this.overtimeMinutes = 0,
    this.breakMinutes,
    this.notes,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int totalWorkingMinutes;
  final int lateMinutes;
  final int overtimeMinutes;
  final int? breakMinutes;
  final String? notes;

  bool get completed => checkInTime != null && checkOutTime != null;
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.workingDays,
    required this.present,
    required this.late,
    required this.absent,
    this.leaveDays = 0,
  });

  final int workingDays;
  final int present;
  final int late;
  final int absent;
  final int leaveDays;
}

/// Everything the Attendance tab needs for one month.
class MonthAttendance {
  const MonthAttendance({
    required this.month,
    required this.summary,
    required this.records,
    required this.calendar,
  });

  final DateTime month;
  final AttendanceSummary summary;
  final List<AttendanceRecord> records; // sorted desc
  final Map<DateTime, AttendanceStatus> calendar;
}