import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../data/location_repository.dart';

enum PickStep { district, upazila, union }

class SelectLocationController extends GetxController {
  final LocationRepository _repository = LocationRepository();

  final step = PickStep.district.obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  final districts = <NamedArea>[].obs;
  final filteredDistricts = <NamedArea>[].obs;
  final upazilas = <NamedArea>[].obs;
  final filteredUpazilas = <NamedArea>[].obs;
  final unions = <UnionRecord>[].obs;
  final filteredUnions = <UnionRecord>[].obs;

  final Rxn<NamedArea> selectedDistrict = Rxn<NamedArea>();
  final Rxn<NamedArea> selectedUpazila = Rxn<NamedArea>();

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadDistricts();
  }

  @override
  void onReady() {
    super.onReady();
    if (UserPrefService().getLat() == null) {
      showExplainDialog();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void showExplainDialog() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final isBangla = Get.locale?.languageCode == 'bn';
      Get.dialog(
        barrierDismissible: false,
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_off, size: 64, color: Colors.blueAccent.shade200),
                const SizedBox(height: 12),
                Text(
                  isBangla ? "লোকেশন পাওয়া যায়নি" : "Location not found",
                  style: AppFonts.style(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  isBangla
                      ? "আপনার এলাকার আবহাওয়া দেখার জন্য দয়া করে তালিকা থেকে আপনার জেলা, উপজেলা ও ইউনিয়ন নির্বাচন করুন।"
                      : "To see your area's weather, please select your district, upazila, and union from the list.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () => Get.back(),
                    child: Text(isBangla ? "ঠিক আছে" : "OK",
                        style: AppFonts.style(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> loadDistricts() async {
    isLoading.value = true;
    try {
      final list = await _repository.districts();
      districts.value = list;
      filteredDistricts.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUpazilas(String districtCode) async {
    isLoading.value = true;
    try {
      final list = await _repository.upazilasOf(districtCode);
      upazilas.value = list;
      filteredUpazilas.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUnions(String districtCode, String upazilaCode) async {
    isLoading.value = true;
    try {
      final list = await _repository.unionsOf(districtCode, upazilaCode);
      unions.value = list;
      filteredUnions.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  void selectDistrict(NamedArea d) {
    selectedDistrict.value = d;
    searchController.clear();
    step.value = PickStep.upazila;
    _loadUpazilas(d.code);
  }

  void selectUpazila(NamedArea u) {
    final district = selectedDistrict.value;
    if (district == null) return;
    selectedUpazila.value = u;
    searchController.clear();
    step.value = PickStep.union;
    _loadUnions(district.code, u.code);
  }

  /// Steps back one level (union -> upazila -> district).
  void back() {
    searchController.clear();
    if (step.value == PickStep.union) {
      selectedUpazila.value = null;
      filteredUnions.value = [];
      step.value = PickStep.upazila;
    } else if (step.value == PickStep.upazila) {
      selectedDistrict.value = null;
      filteredUpazilas.value = [];
      step.value = PickStep.district;
    }
  }

  void search(String query) {
    final lowerQuery = query.toLowerCase();
    switch (step.value) {
      case PickStep.district:
        filteredDistricts.value = query.isEmpty
            ? districts
            : districts
                .where((d) =>
                    d.name.toLowerCase().contains(lowerQuery) ||
                    d.nameBn.toLowerCase().contains(lowerQuery))
                .toList();
        break;
      case PickStep.upazila:
        filteredUpazilas.value = query.isEmpty
            ? upazilas
            : upazilas
                .where((u) =>
                    u.name.toLowerCase().contains(lowerQuery) ||
                    u.nameBn.toLowerCase().contains(lowerQuery))
                .toList();
        break;
      case PickStep.union:
        filteredUnions.value = query.isEmpty
            ? unions
            : unions
                .where((u) =>
                    u.name.toLowerCase().contains(lowerQuery) ||
                    u.nameBn.toLowerCase().contains(lowerQuery))
                .toList();
        break;
    }
  }

  /// Resolves the chosen union through the weather API (the JSON list only
  /// supplies the lat/lon + a fallback name — district/upazila/division come
  /// from the API, matching BMD), persists it as the active location, and
  /// lands on Home.
  Future<void> handleLocationSelection(UnionRecord item) async {
    isSaving.value = true;
    try {
      final isBangla = Get.locale?.languageCode == 'bn';
      final fetched = await UserPrefService().fetchLocationDetailsFromApi(
        lat: item.lat,
        lon: item.lng,
        displayNameFallback: item.name,
        displayNameFallbackBn: item.nameBn,
      );
      if (fetched != null) {
        await UserPrefService().setFollowGPS(false); // manual pick — stop auto-following GPS
        await UserPrefService().saveSelectedLocation(fetched, isBangla: isBangla);
        Get.offAll(() => const HomePage());
      } else {
        Get.snackbar('Error', 'Could not save location');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save location');
    } finally {
      isSaving.value = false;
    }
  }
}
