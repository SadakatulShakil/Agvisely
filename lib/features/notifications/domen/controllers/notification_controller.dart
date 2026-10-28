import 'package:get/get.dart';

import '../../../../core/services/notifications_service.dart';
import '../../../../models/notification_model.dart';
import 'notification_badge_controller.dart';

const _pageLimit = 20;

class NotificationController extends GetxController {
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = Rxn<String>();
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;

  int _page = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _generation = 0;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final myGeneration = ++_generation;
    isLoading.value = true;
    errorMessage.value = null;
    _page = 1;
    _hasMore = true;

    final result = await NotificationsService().fetch(page: _page, limit: _pageLimit);
    if (myGeneration != _generation) return; // superseded by a newer reload

    if (result.items != null) {
      notifications.assignAll(result.items!);
      if (result.unreadCount != null) _setUnreadCount(result.unreadCount!);
      _hasMore = result.meta?.hasMore ?? false;
    } else {
      notifications.clear();
      errorMessage.value = result.error;
    }
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value || isLoading.value) return;

    final myGeneration = _generation;
    isLoadingMore.value = true;
    final result = await NotificationsService().fetch(page: _page + 1, limit: _pageLimit);
    if (myGeneration != _generation) {
      // loadNotifications() reset the list while this was in flight.
      isLoadingMore.value = false;
      return;
    }

    if (result.items != null) {
      _page += 1;
      notifications.addAll(result.items!);
      if (result.unreadCount != null) _setUnreadCount(result.unreadCount!);
      _hasMore = result.meta?.hasMore ?? false;
    }
    // A failed loadMore just leaves _hasMore as-is — the user can retry by
    // scrolling again; the first page's errorMessage path covers hard failures.
    isLoadingMore.value = false;
  }

  /// Marks one notification read — no-op (and no request) if already read.
  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    final result = await NotificationsService().markRead(notification.id);
    if (result.notification == null) return; // leave as unread on failure

    final index = notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) notifications[index] = result.notification!;
    _setUnreadCount(unreadCount.value - 1);
  }

  void _setUnreadCount(int count) {
    unreadCount.value = count < 0 ? 0 : count;
    if (Get.isRegistered<NotificationBadgeController>()) {
      Get.find<NotificationBadgeController>().setUnreadCount(unreadCount.value);
    }
  }
}
