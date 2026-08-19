class Employee {
  const Employee({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.designation,
    required this.joiningDate,
    this.profileImage,
    this.shiftStart,
    this.shiftEnd,
    this.role = 'dealer',
  });

  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String designation;
  final DateTime joiningDate;
  final String? profileImage;
  final String? shiftStart;
  final String? shiftEnd;
  final String role;

  String get firstName => name.split(' ').first;
}