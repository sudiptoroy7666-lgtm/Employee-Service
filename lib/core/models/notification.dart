enum AppNotificationType { attendance, leave, payment, system }

extension AppNotificationTypeLabel on AppNotificationType {
  String get label {
    switch (this) {
      case AppNotificationType.attendance:
        return 'Attendance';
      case AppNotificationType.leave:
        return 'Leave';
      case AppNotificationType.payment:
        return 'Payment';
      case AppNotificationType.system:
        return 'System';
    }
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final AppNotificationType type;
  final DateTime createdAt;
  final bool isRead;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['_id'] as String? ?? j['id'] as String,
        title: j['title'] as String,
        message: j['message'] as String,
        type: AppNotificationType.values.firstWhere(
          (e) => e.name == (j['type'] as String? ?? 'system'),
          orElse: () => AppNotificationType.system,
        ),
        createdAt: DateTime.parse(j['createdAt'] as String),
        isRead: j['isRead'] as bool? ?? false,
      );

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    message: message,
    type: type,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );
}