import '../../models/advisory_item_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/network_exceptions.dart';
import 'user_pref_service.dart';

/// Item catalog for an advisory category's "select an item for advisory"
/// screen — `GET /advisory/categories/{categoryId}/items`. Always hits the
/// network: unlike the home dashboard's category grid (cached for cold
/// start), nothing here needs to survive a navigation away from the page.
class AdvisoryItemsService {
  AdvisoryItemsService._internal();
  static final AdvisoryItemsService _instance = AdvisoryItemsService._internal();
  factory AdvisoryItemsService() => _instance;

  List<AdvisoryItemModel> _normalize(List<AdvisoryItemModel> list) {
    final active = list.where((i) => i.isActive).toList();
    active.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return active;
  }

  /// `items` is non-null (possibly empty — a category can genuinely have no
  /// active items) on success. `error` is a human-readable message on
  /// failure (no connection, timed out, server error, not logged in, ...)
  /// so the caller can show it straight to the user.
  Future<({List<AdvisoryItemModel>? items, String? error})> fetch(int categoryId) async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (items: null, error: 'Please log in again.');
    }

    try {
      final resp = await ApiClient().get(
        ApiEndpoints.advisoryCategoryItems(categoryId),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! List) {
        return (items: null, error: 'Invalid response format received from the server.');
      }

      final raw = data
          .whereType<Map>()
          .map((e) => AdvisoryItemModel.fromJson(e.cast<String, dynamic>()))
          .toList();

      return (items: _normalize(raw), error: null);
    } catch (e) {
      return (items: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }
}
