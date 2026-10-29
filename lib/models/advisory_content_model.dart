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

  /// Plain-text bullets, parsed out of [html]/[htmlBn] — used by the PDF
  final List<AdvisoryBulletModel> bullets;

  /// Raw advisory HTML (as the backend sent it, concatenated across every
  final String html;
  final String? htmlBn;

  const AdvisorySectionModel({
    required this.title,
    this.titleBn,
    this.bullets = const [],
    this.html = '',
    this.htmlBn,
  });

  factory AdvisorySectionModel.fromJson(Map<String, dynamic> j) => AdvisorySectionModel(
        title: j['title']?.toString() ?? '',
        titleBn: j['titleBn']?.toString(),
        bullets: (j['bullets'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => AdvisoryBulletModel.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );

  String label(bool isBn) => isBn && (titleBn != null && titleBn!.isNotEmpty) ? titleBn! : title;

  /// The raw HTML to render for the current locale, falling back to English
  /// when there's no Bangla HTML.
  String content(bool isBn) => isBn && (htmlBn != null && htmlBn!.isNotEmpty) ? htmlBn! : html;
}

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
  /// per-category sections (one per category, rules sharing one merged
  /// together). Rules with no `category` are split three ways:
  /// `stageAdvisory == "IPM"` → one shared "IPM Advisory" section;
  /// `stageAdvisory == "GAP"` → the one highlighted "good practice" card;
  /// anything else → **its own section, keyed by its own `stageAdvisory`**
  /// — e.g. multiple diseases, or multiple named aspects (symptoms/
  /// prevention/...) for one stage, each gets its own titled section
  /// instead of only the first one's name surviving with every other
  /// rule's content silently merged in underneath it unlabeled.
  factory AdvisoryContentModel.fromRules(
    int stageId,
    List<AdvisoryRuleModel> rules, {
    bool ipmOnly = false,
  }) {
    final sections = <AdvisorySectionModel>[];
    final sectionIndexByCategory = <String, int>{};
    final sectionIndexByStageAdvisory = <String, int>{};
    final ipmBullets = <AdvisoryBulletModel>[];
    final goodPracticeBullets = <AdvisoryBulletModel>[];
    var ipmHtml = '';
    var ipmHtmlBn = '';
    var goodPracticeHtml = '';
    var goodPracticeHtmlBn = '';

    final effectiveRules = ipmOnly
        ? rules.where((r) => _isIpmRule(r)).toList()
        : rules;

    for (final rule in effectiveRules) {
      final bullets = _pairBullets(rule.advisory, rule.advisoryBn);
      if (bullets.isEmpty) continue;

      final category = rule.category;
      if (category == null || category.isEmpty) {
        final stageAdvisory = rule.stageAdvisory;
        final lower = stageAdvisory?.toLowerCase();
        if (lower == 'ipm') {
          ipmBullets.addAll(bullets);
          ipmHtml += rule.advisory;
          ipmHtmlBn += rule.advisoryBn;
        } else if (lower == 'gap') {
          goodPracticeBullets.addAll(bullets);
          goodPracticeHtml += rule.advisory;
          goodPracticeHtmlBn += rule.advisoryBn;
        } else {
          // Real stage-rule payloads often leave `stageAdvisory` null on
          // every rule, even when each one is a fully separate advisory
          // document (confirmed against a live response: two rules, both
          // `stageAdvisory: null`, completely different `advisory` HTML).
          // Grouping those by the (identical, empty) `stageAdvisory` value
          // would merge them right back into one block — so only rules
          // that *explicitly* share a real, non-empty name are merged;
          // every null/empty-named rule gets its own section, keyed by its
          // own id so it can never collide with another rule's.
          final key = (lower != null && lower.isNotEmpty) ? lower : 'id:${rule.id}';
          final existingIndex = sectionIndexByStageAdvisory[key];
          if (existingIndex == null) {
            sectionIndexByStageAdvisory[key] = sections.length;
            sections.add(AdvisorySectionModel(
              title: _namedSectionTitle(stageAdvisory),
              bullets: bullets,
              html: rule.advisory,
              htmlBn: rule.advisoryBn,
            ));
          } else {
            final existing = sections[existingIndex];
            sections[existingIndex] = AdvisorySectionModel(
              title: existing.title,
              titleBn: existing.titleBn,
              bullets: [...existing.bullets, ...bullets],
              html: existing.html + rule.advisory,
              htmlBn: (existing.htmlBn ?? '') + rule.advisoryBn,
            );
          }
        }
        continue;
      }

      final key = category.toLowerCase();
      final existingIndex = sectionIndexByCategory[key];
      if (existingIndex == null) {
        sectionIndexByCategory[key] = sections.length;
        final (title, titleBn) = _categorySectionTitle(category);
        sections.add(AdvisorySectionModel(
          title: title,
          titleBn: titleBn,
          bullets: bullets,
          html: rule.advisory,
          htmlBn: rule.advisoryBn,
        ));
      } else {
        final existing = sections[existingIndex];
        sections[existingIndex] = AdvisorySectionModel(
          title: existing.title,
          titleBn: existing.titleBn,
          bullets: [...existing.bullets, ...bullets],
          html: existing.html + rule.advisory,
          htmlBn: (existing.htmlBn ?? '') + rule.advisoryBn,
        );
      }
    }

    if (ipmBullets.isNotEmpty) {
      sections.add(
        AdvisorySectionModel(
          title: 'IPM Advisory',
          titleBn: 'আইপিএম পরামর্শ',
          bullets: ipmBullets,
          html: ipmHtml,
          htmlBn: ipmHtmlBn,
        ),
      );
    }

    AdvisorySectionModel? goodPractice;
    if (goodPracticeBullets.isNotEmpty) {
      goodPractice = AdvisorySectionModel(
        title: 'Good Agriculture Practice',
        titleBn: 'উত্তম কৃষি চর্চা',
        bullets: goodPracticeBullets,
        html: goodPracticeHtml,
        htmlBn: goodPracticeHtmlBn,
      );
    }

    return AdvisoryContentModel(stageId: stageId, sections: sections, goodPractice: goodPractice);
  }

  static bool _isIpmRule(AdvisoryRuleModel rule) =>
      (rule.category == null || rule.category!.isEmpty) &&
      rule.stageAdvisory?.toLowerCase() == 'ipm';

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

  /// Title for a no-`category`, non-IPM, non-GAP rule's own section — e.g.
  /// a disease name, or a named advisory aspect. No Bangla variant exists
  /// for this field on [AdvisoryRuleModel], so it renders as-is in both
  /// languages. Empty when the rule has no `stageAdvisory` at all — these
  /// payloads' only real title (if any) is embedded in the HTML itself
  /// (e.g. an `<h1>`), so callers should skip rendering an external title
  /// row entirely rather than show a placeholder like "General Advisory".
  static String _namedSectionTitle(String? stageAdvisory) =>
      (stageAdvisory == null || stageAdvisory.isEmpty) ? '' : '$stageAdvisory Advisory';
}
