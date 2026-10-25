import 'package:get/get.dart';
import '../../models/advisory_content_model.dart';
import '../../models/advisory_rule_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/network_exceptions.dart';
import 'user_pref_service.dart';

/// Advisory body for a picked stage — `POST /advisory/categories/{categoryId}/
/// items/{itemId}/stages/{stageId}/rules/match` with the user's currently
/// selected location, so the backend returns only the rules matching that
/// location's current weather. Always hits the network, same as
/// [AdvisoryStagesService] — nothing here needs to survive a navigation away.
class AdvisoryContentService {
  AdvisoryContentService._internal();
  static final AdvisoryContentService _instance = AdvisoryContentService._internal();
  factory AdvisoryContentService() => _instance;

  /// `content` is non-null on success. `error` is a human-readable message
  /// on failure. `ipmOnly` keeps just the IPM advisory section — see
  /// [AdvisoryContentModel.fromRules] — for the Pest Advisory flow.
  Future<({AdvisoryContentModel? content, String? error})> fetch(
    int categoryId,
    int itemId,
    int stageId, {
    bool ipmOnly = false,
  }) async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (content: null, error: 'error.login_again'.tr);
    }

    final lat = double.tryParse(UserPrefService().getLat() ?? '');
    final lon = double.tryParse(UserPrefService().getLon() ?? '');
    if (lat == null || lon == null) {
      return (content: null, error: 'error.select_location_first'.tr);
    }

    try {
      final resp = await ApiClient().post(
        ApiEndpoints.advisoryStageRulesMatch(categoryId, itemId, stageId),
        body: {'lat': lat, 'lon': lon},
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! List) {
        return (content: null, error: 'error.invalid_response'.tr);
      }

      final rules = data
          .whereType<Map>()
          .map((e) => AdvisoryRuleModel.fromJson(e.cast<String, dynamic>()))
          .where((r) => r.isActive)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      final content = AdvisoryContentModel.fromRules(stageId, rules, ipmOnly: ipmOnly);
      if (content.sections.isEmpty && content.goodPractice == null) {
        return (content: null, error: 'error.no_advisory_yet'.tr);
      }

      return (content: content, error: null);
    } catch (e) {
      return (content: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }
}
