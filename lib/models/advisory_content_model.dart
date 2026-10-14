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

/// The full advisory body for a stage, from (eventually) `GET /advisory/
/// categories/{categoryId}/items/{itemId}/stages/{stageId}/content`.
/// Demo-JSON-backed for now — see `AdvisoryContentService`.
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

  factory AdvisoryContentModel.fromJson(Map<String, dynamic> j) => AdvisoryContentModel(
        stageId: j['stageId'] is int ? j['stageId'] as int : 0,
        titleBn: j['titleBn']?.toString(),
        sections: (j['sections'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => AdvisorySectionModel.fromJson(e.cast<String, dynamic>()))
            .toList(),
        goodPractice: j['goodPractice'] is Map
            ? AdvisorySectionModel.fromJson((j['goodPractice'] as Map).cast<String, dynamic>())
            : null,
      );

}
