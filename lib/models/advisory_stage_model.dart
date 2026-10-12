import 'package:intl/intl.dart';

/// One row of an advisory item's "select a stage for advisory" list, from
/// `GET /advisory/categories/{categoryId}/items/{itemId}/stages`.
class AdvisoryStageModel {
  final int id;
  final int itemId;
  final String name;
  final String? nameBn;
  final String? imageUrl; // relative path — resolve via ApiEndpoints.baseUrlUserHost
  final DateTime? startDate;
  final DateTime? endDate;
  final int sortOrder;
  final bool isActive;

  const AdvisoryStageModel({
    required this.id,
    required this.itemId,
    required this.name,
    this.nameBn,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory AdvisoryStageModel.fromJson(Map<String, dynamic> j) => AdvisoryStageModel(
        id: j['id'] as int,
        itemId: j['itemId'] is int ? j['itemId'] as int : 0,
        name: j['name']?.toString() ?? '',
        nameBn: j['nameBn']?.toString(),
        imageUrl: j['imageUrl']?.toString(),
        startDate: DateTime.tryParse(j['startDate']?.toString() ?? ''),
        endDate: DateTime.tryParse(j['endDate']?.toString() ?? ''),
        sortOrder: j['sortOrder'] is int ? j['sortOrder'] as int : 0,
        isActive: j['isActive'] != false,
      );

  String label(bool isBn) =>
      isBn && (nameBn != null && nameBn!.isNotEmpty) ? nameBn! : name;

  /// e.g. "01 November-05 December" — empty when either date is missing.
  String dateRangeLabel(bool isBn) {
    final s = startDate, e = endDate;
    if (s == null || e == null) return '';
    final fmt = DateFormat('dd MMMM', isBn ? 'bn' : 'en');
    return '${fmt.format(s)}-${fmt.format(e)}';
  }
}
