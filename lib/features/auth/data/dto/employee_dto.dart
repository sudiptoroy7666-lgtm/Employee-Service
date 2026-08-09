class EmployeeDto {
  EmployeeDto.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        employeeId = j['employeeId']?.toString() ?? '',
        name = j['fullName']?.toString() ?? j['username']?.toString() ?? '',
        email = j['email']?.toString() ?? '',
        phone = j['contact']?.toString() ?? '',
        department = '', // Not in this response — might need separate endpoint
        designation = (j['role'] is Map ? j['role']['value'] : j['role'])?.toString() ?? '',
        joiningDate = j['joiningDate'] != null
            ? DateTime.tryParse(j['joiningDate'].toString())
            : null,
        shiftStart = j['shiftStart']?.toString(),
        shiftEnd = j['shiftEnd']?.toString(),
        locationBoundedAttendance = j['locationBoundedAttendance'] as bool? ?? false;

  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String designation;
  final DateTime? joiningDate;
  final String? shiftStart;
  final String? shiftEnd;
  final bool locationBoundedAttendance;
}