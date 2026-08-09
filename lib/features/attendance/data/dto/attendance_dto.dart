class TodayAttendanceDto {
  TodayAttendanceDto.fromJson(Map<String, dynamic> j)
      : checkInTime = j['checkInTime'] != null
            ? DateTime.tryParse(j['checkInTime'].toString())
            : null,
        checkOutTime = j['checkOutTime'] != null
            ? DateTime.tryParse(j['checkOutTime'].toString())
            : null,
        status = j['status']?.toString() ?? '';

  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;

  bool get isCheckedIn => checkInTime != null;
}

class AttendanceReportItemDto {
  AttendanceReportItemDto.fromJson(Map<String, dynamic> j)
      : date = DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        status = j['status']?.toString() ?? j['state']?.toString(),
        checkInTime = j['checkInTime'] != null ? DateTime.tryParse(j['checkInTime'].toString()) : null,
        checkOutTime = j['checkOutTime'] != null ? DateTime.tryParse(j['checkOutTime'].toString()) : null,
        totalMinutes = (j['totalMinutes'] ?? j['totalWorkingMinutes'] ?? j['workedMinutes'] ?? 0).toInt(),
        lateMinutes = (j['lateMinutes'] ?? 0).toInt(),
        overtimeMinutes = (j['overtimeMinutes'] ?? 0).toInt();

  final DateTime date;
  final String? status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int totalMinutes;
  final int lateMinutes;
  final int overtimeMinutes;
}