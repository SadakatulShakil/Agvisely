import '../../models/advisory_category_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'user_pref_service.dart';

/// Home dashboard's advisory grid catalog — cache-then-network, same shape
/// as [ProfessionsService]: in-memory first, then whatever was last
/// persisted from a successful fetch, refreshed in the background.
class AdvisoryCategoriesService {
  AdvisoryCategoriesService._internal();
  static final AdvisoryCategoriesService _instance =
      AdvisoryCategoriesService._internal();
  factory AdvisoryCategoriesService() => _instance;

  List<AdvisoryCategoryModel>? _memCache;

  /// Active-only, sortOrder-sorted — enforced here so it holds regardless
  /// of whether the data came from a fresh [fetch] or the persisted cache
  /// (e.g. if a category is deactivated server-side, the next cold start
  /// reading stale persisted data still hides it after normalization).
  List<AdvisoryCategoryModel>? get cached {
    if (_memCache != null) return _memCache;
    final persisted = UserPrefService().cachedAdvisoryCategories;
    if (persisted == null) return null;
    return _memCache = _normalize(persisted);
  }

  List<AdvisoryCategoryModel> _normalize(List<AdvisoryCategoryModel> list) {
    final active = list.where((c) => c.isActive).toList();
    active.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return active;
  }

  /// Fetches the live catalog and persists it. Returns null (cache left
  /// untouched) on any failure.
  Future<List<AdvisoryCategoryModel>?> fetch() async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) return null; // not logged in

    try {
      final resp = await ApiClient().get(
        ApiEndpoints.advisoryCategories,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      final raw = data is List
          ? data
              .whereType<Map>()
              .map((e) => AdvisoryCategoryModel.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <AdvisoryCategoryModel>[];

      if (raw.isEmpty) return null;

      final normalized = _normalize(raw);
      if (normalized.isEmpty) return null;

      _memCache = normalized;
      await UserPrefService().setCachedAdvisoryCategories(normalized);
      return normalized;
    } catch (_) {
      return null;
    }
  }
}
