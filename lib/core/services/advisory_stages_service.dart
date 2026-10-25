import 'package:get/get.dart';
import '../../models/advisory_stage_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/network_exceptions.dart';
import 'user_pref_service.dart';

/// Stage list for a picked advisory item — `GET /advisory/categories/
/// {categoryId}/items/{itemId}/stages`. Always hits the network, same as
/// [AdvisoryItemsService] — nothing here needs to survive a navigation away.
class AdvisoryStagesService {
  AdvisoryStagesService._internal();
  static final AdvisoryStagesService _instance = AdvisoryStagesService._internal();
  factory AdvisoryStagesService() => _instance;

  List<AdvisoryStageModel> _normalize(List<AdvisoryStageModel> list) {
    final active = list.where((s) => s.isActive).toList();
    active.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return active;
  }

  /// `stages` is non-null (possibly empty) on success. `error` is a
  /// human-readable message on failure. `stageCategory` is `'disease'` for
  /// the Crop Disease Early Warning flow; left out (or `null`) it fetches
  /// the item's advisory stages.
  Future<({List<AdvisoryStageModel>? stages, String? error})> fetch(
    int categoryId,
    int itemId, {
    String? stageCategory,
  }) async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (stages: null, error: 'error.login_again'.tr);
    }

    try {
      final resp = await ApiClient().get(
        ApiEndpoints.advisoryItemStages(categoryId, itemId, stageCategory: stageCategory),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! List) {
        return (stages: null, error: 'error.invalid_response'.tr);
      }

      final raw = data
          .whereType<Map>()
          .map((e) => AdvisoryStageModel.fromJson(e.cast<String, dynamic>()))
          .toList();

      return (stages: _normalize(raw), error: null);
    } catch (e) {
      return (stages: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }
}
