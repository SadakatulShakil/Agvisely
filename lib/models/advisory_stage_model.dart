import 'package:intl/intl.dart';

/// One row of an advisory item's "select a stage for advisory" list, from
/// `GET /advisory/categories/{categoryId}/items/{itemId}/stages`.
class AdvisoryStageModel {
  final int id;
  final int itemId;
  final String name;
  final String? nameBn;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? stage;
  final String? category;
  final String? icon;
  final String? imageUrl; // relative path — resolve via ApiEndpoints.baseUrlUserHost
  final String? description;
  final String? descriptionBn;
  final num? minimumThreshold;
  final num? maximumThreshold;
  final String? stageAdvisory;
  final String? stageAdvisoryBn;
  final int sortOrder;
  final bool isActive;

  const AdvisoryStageModel({
    required this.id,
    required this.itemId,
    required this.name,
    this.nameBn,
    this.startDate,
    this.endDate,
    this.stage,
    this.category,
    this.icon,
    this.imageUrl,
    this.description,
    this.descriptionBn,
    this.minimumThreshold,
    this.maximumThreshold,
    this.stageAdvisory,
    this.stageAdvisoryBn,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory AdvisoryStageModel.fromJson(Map<String, dynamic> j) => AdvisoryStageModel(
        id: j['id'] as int,
        itemId: j['itemId'] is int ? j['itemId'] as int : 0,
        name: j['name']?.toString() ?? '',
        nameBn: j['nameBn']?.toString(),
        startDate: DateTime.tryParse(j['startDate']?.toString() ?? ''),
        endDate: DateTime.tryParse(j['endDate']?.toString() ?? ''),
        stage: j['stage']?.toString(),
        category: j['category']?.toString(),
        icon: j['icon']?.toString(),
        imageUrl: j['imageUrl']?.toString(),
        description: j['description']?.toString(),
        descriptionBn: j['descriptionBn']?.toString(),
        minimumThreshold: j['minimumThreshold'] as num?,
        maximumThreshold: j['maximumThreshold'] as num?,
        stageAdvisory: j['stageAdvisory']?.toString(),
        stageAdvisoryBn: j['stageAdvisoryBn']?.toString(),
        sortOrder: j['sortOrder'] is int ? j['sortOrder'] as int : 0,
        isActive: j['isActive'] != false,
      );

  String label(bool isBn) =>
      isBn && (nameBn != null && nameBn!.isNotEmpty) ? nameBn! : name;

  String descriptionLabel(bool isBn) =>
      isBn && (descriptionBn != null && descriptionBn!.isNotEmpty)
          ? descriptionBn!
          : (description ?? '');

  /// "1 November - 5 December" style range for the stage list — both dates are
  String dateRangeLabel(bool isBn) {
    final start = startDate;
    final end = endDate;
    if (start == null && end == null) return '';

    final fmt = DateFormat('d MMMM', isBn ? 'bn' : 'en');
    if (start != null && end != null) {
      return '${fmt.format(start)} - ${fmt.format(end)}';
    }
    return start != null ? fmt.format(start) : fmt.format(end!);
  }
}
