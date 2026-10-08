import 'package:get/get.dart';

import '../../../../models/seven_day_model.dart';
import '../../data/seven_day_repository.dart';

/// 7-Day Weather Forecast — screen state.
class SevenDayController extends GetxController {
  final _repository = SevenDayRepository();

  final isLoading = false.obs;
  final days = <DayForecast>[].obs;

  /// The one day whose graph is expanded — null means all collapsed.
  final expandedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Also called by SettingsController on a language switch — the
  /// repository's own lang-keyed cache picks up the new locale's JSON.
  Future<void> load() async {
    isLoading.value = true;
    try {
      final result = await _repository.load();
      days.assignAll(result);
      // No card auto-expands — the user opens a graph explicitly.
    } finally {
      isLoading.value = false;
    }
  }

  void toggleExpanded(DateTime date) {
    expandedDate.value = _sameDay(expandedDate.value, date) ? null : date;
  }

  bool isExpanded(DateTime date) => _sameDay(expandedDate.value, date);

  bool _sameDay(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;
}
