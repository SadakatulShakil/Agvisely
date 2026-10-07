import 'package:get/get.dart';

import '../../models/profession_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'user_pref_service.dart';

/// Shared profession catalog — the single source both the sign-up dropdown
/// and the Profile subtitle resolve a professionId against, so they don't
/// each fetch (and potentially disagree) independently.
///
/// [cached] only ever holds real, server-sourced data (in-memory, then
/// whatever was last persisted from a successful [fetch]). It deliberately
/// does NOT fall back to placeholder data — a professionId resolved against
/// a made-up id→name table could show the wrong profession entirely.
/// Callers that need a non-empty dropdown even when offline (sign-up) are
/// responsible for their own placeholder list.
class ProfessionsService {
  ProfessionsService._internal();
  static final ProfessionsService _instance = ProfessionsService._internal();
  factory ProfessionsService() => _instance;

  List<ProfessionModel>? _memCache;

  List<ProfessionModel>? get cached =>
      _memCache ??= UserPrefService().cachedProfessions;

  ProfessionModel? byId(int id) => cached?.firstWhereOrNull((p) => p.id == id);

  /// Fetches the live catalog and persists it. Returns null (cache left
  /// untouched) on any failure.
  Future<List<ProfessionModel>?> fetch() async {
    try {
      final resp = await ApiClient().get(ApiEndpoints.professions);
      final data = resp is Map ? resp['data'] : null;
      final list = data is List
          ? data
              .whereType<Map>()
              .map((e) => ProfessionModel.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <ProfessionModel>[];

      if (list.isEmpty) return null;

      _memCache = list;
      await UserPrefService().setCachedProfessions(list);
      return list;
    } catch (_) {
      return null;
    }
  }
}
