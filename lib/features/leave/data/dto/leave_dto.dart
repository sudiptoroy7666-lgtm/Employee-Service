class LeaveRequestDto {
  LeaveRequestDto.fromJson(Map<String, dynamic> j)
      : id = (j['id'] ?? j['_id'])?.toString() ?? '',
        leaveType = (j['leaveType']?['value'] ?? j['leaveTypeId'] ?? 'annual').toString(),
        startDate = DateTime.tryParse(j['startDate']?.toString() ?? '') ?? DateTime.now(),
        endDate = DateTime.tryParse(j['endDate']?.toString() ?? '') ?? DateTime.now(),
        numberOfDays = (j['numberOfDays'] ?? j['days'] ?? 0).toInt(),
        reason = j['reason']?.toString() ?? '',
        status = (j['status']?['value'] ?? j['status'] ?? 'pending').toString(),
        submittedAt = j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        reviewerComment = j['reviewerComment']?.toString();

  final String id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfDays;
  final String reason;
  final String status;
  final DateTime submittedAt;
  final String? reviewerComment;
}

class LeaveBalanceDto {
  // Backend returns a single combined balance, not per-type
  LeaveBalanceDto.fromJson(Map<String, dynamic> j)
      : allocatedDays = (j['allocatedDays'] ?? 0).toInt(),
        usedDays = (j['usedDays'] ?? 0).toInt(),
        remainingDays = (j['remainingDays'] ?? 0).toInt();

  final int allocatedDays;
  final int usedDays;
  final int remainingDays;
}