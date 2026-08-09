enum ActivityType { checkIn, checkOut, leaveSubmitted, leaveApproved, payment }

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.occurredAt,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime occurredAt;
}