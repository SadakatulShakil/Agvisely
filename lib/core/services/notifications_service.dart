import 'package:get/get.dart';
import '../../models/notification_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/network_exceptions.dart';
import 'user_pref_service.dart';

/// The current user's notification inbox — `GET /notifications`. Always
/// hits the network; the caller (controller) owns pagination state.
class NotificationsService {
  NotificationsService._internal();
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;

  /// `items`/`meta`/`unreadCount` are non-null on success. `error` is a
  /// human-readable message on failure.
  Future<({
    List<NotificationModel>? items,
    NotificationPageMeta? meta,
    int? unreadCount,
    String? error,
  })> fetch({int page = 1, int limit = 20, String order = 'desc'}) async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (items: null, meta: null, unreadCount: null, error: 'error.login_again'.tr);
    }

    try {
      final resp = await ApiClient().get(
        ApiEndpoints.notifications(page: page, limit: limit, order: order),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! Map && data is! List) {
        return (
          items: null,
          meta: null,
          unreadCount: null,
          error: 'error.invalid_response'.tr,
        );
      }

      // The server may return `data` as either the flat array of
      // notifications, or (older shape) `{items, meta, unreadCount}`.
      final rawItems = data is List ? data : (data as Map)['items'];
      final items = rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => NotificationModel.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <NotificationModel>[];

      final rawMeta = data is Map ? data['meta'] : null;
      final meta = rawMeta is Map
          ? NotificationPageMeta.fromJson(rawMeta.cast<String, dynamic>())
          // No pagination meta from the server (flat-array shape) — infer
          // `hasMore` from whether this page came back full.
          : NotificationPageMeta(
              page: page,
              limit: limit,
              total: items.length,
              totalPages: items.length >= limit ? page + 1 : page,
            );

      final rawUnreadCount = data is Map ? data['unreadCount'] : null;
      // The flat-array shape doesn't send an aggregate `unreadCount` — fall
      // back to counting unread items on this page.
      final unreadCount =
          rawUnreadCount is int ? rawUnreadCount : items.where((n) => !n.isRead).length;

      return (items: items, meta: meta, unreadCount: unreadCount, error: null);
    } catch (e) {
      return (
        items: null,
        meta: null,
        unreadCount: null,
        error: NetworkExceptions.getErrorMessage(e),
      );
    }
  }

  /// `notification` is non-null (with `isRead: true`) on success.
  Future<({NotificationModel? notification, String? error})> markRead(int id) async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (notification: null, error: 'error.login_again'.tr);
    }

    try {
      final resp = await ApiClient().put(
        ApiEndpoints.notificationMarkRead(id),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! Map) {
        return (notification: null, error: 'error.invalid_response'.tr);
      }
      return (notification: NotificationModel.fromJson(data.cast<String, dynamic>()), error: null);
    } catch (e) {
      return (notification: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }
}
