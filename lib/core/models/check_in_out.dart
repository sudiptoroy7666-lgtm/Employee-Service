enum WorkdayStatus { notStarted, working, completed }

class CheckInOutRecord {
  const CheckInOutRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.breakStart,
    this.breakEnd,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime? breakStart;
  final DateTime? breakEnd;

  WorkdayStatus get status {
    if (checkInTime == null) return WorkdayStatus.notStarted;
    if (checkOutTime == null) return WorkdayStatus.working;
    return WorkdayStatus.completed;
  }

  int workingMinutes(DateTime now) {
    if (checkInTime == null) return 0;
    final end = checkOutTime ?? now;
    return end.difference(checkInTime!).inMinutes;
  }

  CheckInOutRecord copyWith({DateTime? checkInTime, DateTime? checkOutTime}) => CheckInOutRecord(
    id: id,
    employeeId: employeeId,
    date: date,
    checkInTime: checkInTime ?? this.checkInTime,
    checkOutTime: checkOutTime ?? this.checkOutTime,
    breakStart: breakStart,
    breakEnd: breakEnd,
  );
}