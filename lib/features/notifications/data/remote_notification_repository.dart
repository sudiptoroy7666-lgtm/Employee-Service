import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/notification.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/api_utils.dart';
import '../domain/repositories/notification_repository.dart';

class RemoteNotificationRepository implements NotificationRepository {
  RemoteNotificationRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final res = await _client.dio.get(ApiEndpoints.notifications);
    return extractList(res.data)
        .map<AppNotification>((j) => AppNotification.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async =>
      _client.dio.patch('${ApiEndpoints.notifications}/$id/read');

  @override
  Future<void> markAllAsRead() async => _client.dio.patch(ApiEndpoints.notificationsRead);
}