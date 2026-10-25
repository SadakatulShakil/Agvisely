import 'package:get/get.dart';

import '../../../../core/services/notifications_service.dart';

/// App-wide unread notification count for the home page bell badge.
/// Registered once (permanent) and kept in sync by [NotificationController]
/// whenever it loads or marks notifications, so the badge updates live
/// without this controller making its own extra requests.
class NotificationBadgeController extends GetxController {
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshUnreadCount();
  }

  /// `limit: 1` — only `unreadCount` is needed, not the items.
  Future<void> refreshUnreadCount() async {
    final result = await NotificationsService().fetch(page: 1, limit: 1);
    if (result.unreadCount != null) {
      unreadCount.value = result.unreadCount!;
    }
  }

  void setUnreadCount(int count) => unreadCount.value = count < 0 ? 0 : count;

  void decrement([int by = 1]) {
    final next = unreadCount.value - by;
    unreadCount.value = next < 0 ? 0 : next;
  }

  void clear() => unreadCount.value = 0;
}
