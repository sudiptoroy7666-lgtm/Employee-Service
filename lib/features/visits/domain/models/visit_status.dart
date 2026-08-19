enum VisitStatus {
  pending,
  checkedIn,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.checkedIn:
        return 'Checked In';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.cancelled:
        return 'Cancelled';
    }
  }
}
