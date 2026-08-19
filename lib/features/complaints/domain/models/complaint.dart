class Complaint {
  final String id;
  final String clientName;
  final String subject;
  final String description;
  final DateTime submittedDate;
  final ComplaintStatus status;
  final ComplaintPriority priority;

  Complaint({
    required this.id,
    required this.clientName,
    required this.subject,
    required this.description,
    required this.submittedDate,
    required this.status,
    required this.priority,
  });
}

enum ComplaintStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get label {
    switch (this) {
      case ComplaintStatus.open:
        return 'Open';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.closed:
        return 'Closed';
    }
  }
}

enum ComplaintPriority {
  low,
  medium,
  high,
  urgent;

  String get label {
    switch (this) {
      case ComplaintPriority.low:
        return 'Low';
      case ComplaintPriority.medium:
        return 'Medium';
      case ComplaintPriority.high:
        return 'High';
      case ComplaintPriority.urgent:
        return 'Urgent';
    }
  }
}
