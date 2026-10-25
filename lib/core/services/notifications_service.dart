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
      return (items: null, meta: null, unreadCount: null, error: 'Please log in again.');
    }

    try {
      final resp = await ApiClient().get(
        ApiEndpoints.notifications(page: page, limit: limit, order: order),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! Map) {
        return (
          items: null,
          meta: null,
          unreadCount: null,
          error: 'Invalid response format received from the server.',
        );
      }

      final rawItems = data['items'];
      final items = rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => NotificationModel.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <NotificationModel>[];

      final rawMeta = data['meta'];
      final meta = rawMeta is Map
          ? NotificationPageMeta.fromJson(rawMeta.cast<String, dynamic>())
          : NotificationPageMeta(page: page, limit: limit, total: items.length, totalPages: 1);

      final unreadCount = data['unreadCount'] is int ? data['unreadCount'] as int : 0;

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
      return (notification: null, error: 'Please log in again.');
    }

    try {
      final resp = await ApiClient().put(
        ApiEndpoints.notificationMarkRead(id),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! Map) {
        return (notification: null, error: 'Invalid response format received from the server.');
      }
      return (notification: NotificationModel.fromJson(data.cast<String, dynamic>()), error: null);
    } catch (e) {
      return (notification: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }

  /// `count` (non-null on success) is how many were newly marked as read.
  Future<({int? count, String? error})> markAllRead() async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (count: null, error: 'Please log in again.');
    }

    try {
      final resp = await ApiClient().put(
        ApiEndpoints.notificationMarkAllRead,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! int) {
        return (count: null, error: 'Invalid response format received from the server.');
      }
      return (count: data, error: null);
    } catch (e) {
      return (count: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }
}
