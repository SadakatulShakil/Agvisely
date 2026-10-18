import '../core/utils/html_bullets.dart';
import 'advisory_rule_model.dart';

/// One bullet line inside an [AdvisorySectionModel].
class AdvisoryBulletModel {
  final String text;
  final String? textBn;

  const AdvisoryBulletModel({required this.text, this.textBn});

  factory AdvisoryBulletModel.fromJson(Map<String, dynamic> j) => AdvisoryBulletModel(
        text: j['text']?.toString() ?? '',
        textBn: j['textBn']?.toString(),
      );

  String label(bool isBn) => isBn && (textBn != null && textBn!.isNotEmpty) ? textBn! : text;
}

/// A titled group of bullets, e.g. "Temperature Related Advisory" or the
/// highlighted "Good Agriculture Practice" block.
class AdvisorySectionModel {
  final String title;
  final String? titleBn;
  final List<AdvisoryBulletModel> bullets;

  const AdvisorySectionModel({required this.title, this.titleBn, this.bullets = const []});

  factory AdvisorySectionModel.fromJson(Map<String, dynamic> j) => AdvisorySectionModel(
        title: j['title']?.toString() ?? '',
        titleBn: j['titleBn']?.toString(),
        bullets: (j['bullets'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => AdvisoryBulletModel.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );

  String label(bool isBn) => isBn && (titleBn != null && titleBn!.isNotEmpty) ? titleBn! : title;
}

/// The full advisory body for a stage, built from `POST /advisory/categories/
/// {categoryId}/items/{itemId}/stages/{stageId}/rules/match` — see
/// `AdvisoryContentService` and [AdvisoryContentModel.fromRules].
class AdvisoryContentModel {
  final int stageId;
  final String? titleBn;
  final List<AdvisorySectionModel> sections;
  final AdvisorySectionModel? goodPractice;

  const AdvisoryContentModel({
    required this.stageId,
    this.titleBn,
    this.sections = const [],
    this.goodPractice,
  });

  /// Groups the stage's active rules into display sections: rules with a
  /// `category` (`"temperature"`, `"rainfall"`, ...) become ordinary
  /// sections (one per category, in first-seen order, bullets concatenated
  /// across every rule sharing that category); rules with no `category`
  /// (e.g. `stageAdvisory == "IPM"`, which applies unconditionally rather
  /// than on a weather threshold) are pooled into the highlighted
  /// "good practice" card. Each rule's `advisory`/`advisoryBn` HTML list is
  /// parsed into plain-text bullets and paired up by position.
  factory AdvisoryContentModel.fromRules(int stageId, List<AdvisoryRuleModel> rules) {
    final sections = <AdvisorySectionModel>[];
    final sectionIndexByCategory = <String, int>{};
    final goodPracticeBullets = <AdvisoryBulletModel>[];
    String? goodPracticeKey;

    for (final rule in rules) {
      final bullets = _pairBullets(rule.advisory, rule.advisoryBn);
      if (bullets.isEmpty) continue;

      final category = rule.category;
      if (category == null || category.isEmpty) {
        goodPracticeKey ??= rule.stageAdvisory;
        goodPracticeBullets.addAll(bullets);
        continue;
      }

      final key = category.toLowerCase();
      final existingIndex = sectionIndexByCategory[key];
      if (existingIndex == null) {
        sectionIndexByCategory[key] = sections.length;
        final (title, titleBn) = _categorySectionTitle(category);
        sections.add(AdvisorySectionModel(title: title, titleBn: titleBn, bullets: bullets));
      } else {
        final existing = sections[existingIndex];
        sections[existingIndex] = AdvisorySectionModel(
          title: existing.title,
          titleBn: existing.titleBn,
          bullets: [...existing.bullets, ...bullets],
        );
      }
    }

    AdvisorySectionModel? goodPractice;
    if (goodPracticeBullets.isNotEmpty) {
      final (title, titleBn) = _goodPracticeSectionTitle(goodPracticeKey);
      goodPractice = AdvisorySectionModel(title: title, titleBn: titleBn, bullets: goodPracticeBullets);
    }

    return AdvisoryContentModel(stageId: stageId, sections: sections, goodPractice: goodPractice);
  }

  static List<AdvisoryBulletModel> _pairBullets(String advisory, String advisoryBn) {
    final en = parseHtmlBullets(advisory);
    final bn = parseHtmlBullets(advisoryBn);
    final count = en.length > bn.length ? en.length : bn.length;
    return [
      for (var i = 0; i < count; i++)
        AdvisoryBulletModel(
          text: i < en.length ? en[i] : bn[i],
          textBn: i < bn.length ? bn[i] : null,
        ),
    ];
  }

  static (String, String?) _categorySectionTitle(String category) {
    switch (category.toLowerCase()) {
      case 'temperature':
        return ('Temperature Related Advisory', 'তাপমাত্রা সংক্রান্ত পরামর্শ');
      case 'rainfall':
        return ('Rainfall Related Advisory', 'বৃষ্টিপাত সংক্রান্ত পরামর্শ');
      default:
        return ('${category[0].toUpperCase()}${category.substring(1)} Related Advisory', null);
    }
  }

  static (String, String?) _goodPracticeSectionTitle(String? stageAdvisory) {
    if (stageAdvisory == null || stageAdvisory.isEmpty) return ('General Advisory', null);
    if (stageAdvisory.toLowerCase() == 'ipm') return ('IPM Advisory', 'আইপিএম পরামর্শ');
    return ('$stageAdvisory Advisory', null);
  }
}
