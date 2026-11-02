import 'package:get/get.dart';
import '../../models/custom_code_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/network_exceptions.dart';
import 'user_pref_service.dart';

/// The Menu tab's dynamic item tree — `GET /custom-codes`. Always hits the
/// network. A `'list'` node's `children` may come back empty in this root
/// fetch even when it conceptually has some — [fetchNode] lazily loads a
/// specific node's own children on demand (when the user taps into it).
class CustomCodesService {
  CustomCodesService._internal();
  static final CustomCodesService _instance = CustomCodesService._internal();
  factory CustomCodesService() => _instance;

  /// `items` is non-null on success. `error` is a human-readable message on
  /// failure.
  Future<({List<CustomCodeModel>? items, String? error})> fetch() async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (items: null, error: 'error.login_again'.tr);
    }

    try {
      final resp = await ApiClient().get(
        ApiEndpoints.customCodes,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! List) {
        return (items: null, error: 'error.invalid_response'.tr);
      }

      final items = data
          .whereType<Map>()
          .map((e) => CustomCodeModel.fromJson(e.cast<String, dynamic>()))
          .where((c) => c.isActive)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return (items: items, error: null);
    } catch (e) {
      return (items: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }

  /// `GET /custom-codes/{id}` — the same node, now with its `children`
  /// populated. `node` is non-null on success.
  Future<({CustomCodeModel? node, String? error})> fetchNode(int id) async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (node: null, error: 'error.login_again'.tr);
    }

    try {
      final resp = await ApiClient().get(
        ApiEndpoints.customCode(id),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! Map) {
        return (node: null, error: 'error.invalid_response'.tr);
      }

      return (node: CustomCodeModel.fromJson(data.cast<String, dynamic>()), error: null);
    } catch (e) {
      return (node: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }
}
