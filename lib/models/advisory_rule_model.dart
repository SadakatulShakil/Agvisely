/// One advisory rule for a stage, from `POST /advisory/categories/
/// {categoryId}/items/{itemId}/stages/{stageId}/rules/match` — already
/// matched by the backend against the posted location's current weather.
/// `category == null` rules (e.g. `stageAdvisory == "IPM"`) apply
/// unconditionally; the rest were weather-threshold triggers (`category` is
/// `"temperature"`, `"rainfall"`, ...) — see [AdvisoryContentModel.fromRules].
class AdvisoryRuleModel {
  final int id;
  final int stageId;
  final String? stageAdvisory;
  final String? category;
  final String advisory;
  final String advisoryBn;
  final int? drySpell;
  final num? minThreshold;
  final num? maxThreshold;
  final int sortOrder;
  final bool isActive;

  const AdvisoryRuleModel({
    required this.id,
    required this.stageId,
    this.stageAdvisory,
    this.category,
    this.advisory = '',
    this.advisoryBn = '',
    this.drySpell,
    this.minThreshold,
    this.maxThreshold,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory AdvisoryRuleModel.fromJson(Map<String, dynamic> j) => AdvisoryRuleModel(
        id: j['id'] is int ? j['id'] as int : 0,
        stageId: j['stageId'] is int ? j['stageId'] as int : 0,
        stageAdvisory: j['stageAdvisory']?.toString(),
        category: j['category']?.toString(),
        advisory: j['advisory']?.toString() ?? '',
        advisoryBn: j['advisoryBn']?.toString() ?? '',
        drySpell: j['drySpell'] is int ? j['drySpell'] as int : null,
        minThreshold: j['minThreshold'] as num?,
        maxThreshold: j['maxThreshold'] as num?,
        sortOrder: j['sortOrder'] is int ? j['sortOrder'] as int : 0,
        isActive: j['isActive'] != false,
      );
}
