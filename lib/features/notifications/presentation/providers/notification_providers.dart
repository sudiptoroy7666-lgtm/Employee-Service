import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/notification.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_notification_repository.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
      (ref) => RemoteNotificationRepository(ref.read(apiClientProvider)),
  name: 'notificationRepository',
);

final notificationsProvider = StateNotifierProvider<NotificationsController, AsyncValue<List<AppNotification>>>(
      (ref) => NotificationsController(ref.read(notificationRepositoryProvider)),
  name: 'notifications',
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
}, name: 'unreadCount');

class NotificationsController extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsController(this._repository) : super(const AsyncLoading()) {
    refresh();
  }

  final NotificationRepository _repository;

  Future<void> refresh() async {
    final prev = state;
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.getNotifications());
    } catch (e, st) {
      state = prev is AsyncData<List<AppNotification>> ? prev : AsyncError(e, st);
    }
  }

  Future<void> markRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList());
    await _repository.markAsRead(id);
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.map((n) => n.copyWith(isRead: true)).toList());
    await _repository.markAllAsRead();
  }
}