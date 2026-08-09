enum LeaveType { annual, sick, casual, unpaid }

extension LeaveTypeLabel on LeaveType {
  String get label {
    switch (this) {
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.casual:
        return 'Casual Leave';
      case LeaveType.unpaid:
        return 'Unpaid Leave';
    }
  }
}

enum LeaveStatus { pending, approved, rejected }

extension LeaveStatusLabel on LeaveStatus {
  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }
}

class NewLeaveRequest {
  const NewLeaveRequest({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.reason,
  });

  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfDays;
  final String reason;
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.reason,
    required this.status,
    required this.submittedAt,
    this.reviewerName,
    this.reviewerComment,
    this.reviewedAt,
    this.isLocalOnly = false,
  });

  final String id;
  final String employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfDays;
  final String reason;
  final LeaveStatus status;
  final DateTime submittedAt;
  final String? reviewerName;
  final String? reviewerComment;
  final DateTime? reviewedAt;
  final bool isLocalOnly;
}

class LeaveBalance {
  const LeaveBalance({required this.type, required this.totalDays, required this.usedDays});

  final LeaveType type;
  final int totalDays;
  final int usedDays;

  int get remainingDays => totalDays - usedDays;
  double get usedFraction => totalDays == 0 ? 0 : usedDays / totalDays;
}
