import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../features/auth/auth/presentation/pages/login_page.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../data/location_repository.dart';
import '../../models/location_gate_destination.dart';

class SelectLocationController extends GetxController {
  final LocationRepository _repository = LocationRepository();

  // Where to land after a location is picked — set by SelectLocationPage
  // right before build(). Only meaningful when reached via the first-install
  // location gate; the settings-triggered picker (isFirstInstall: false)
  // never touches it.
  LocationGateDestination destination = LocationGateDestination.home;

  // State
  final all = <UnionRecord>[].obs;
  final filtered = <UnionRecord>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final UserPrefService userService = UserPrefService();

  // UI Controls
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUnions();
  }

  @override
  void onReady() {
    super.onReady();

    if (UserPrefService().getLat() == null) {
      showExplainDialog();
    }
  }

  void showExplainDialog() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final isBangla = Get.locale?.languageCode == 'bn';
      Get.dialog(
        barrierDismissible: false, // Prevents closing by clicking outside
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
                      ? "আপনার এলাকার আবহাওয়া দেখার জন্য দয়া করে তালিকা থেকে আপনার উপজেলা বা জেলাটি খুঁজে নিন।"
                      : "To see your area's weather, please select your Upazila or District from the list.",
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

  Future<void> loadUnions() async {
    isLoading.value = true;
    try {
      final list = await _repository.allUnions();
      all.value = list;
      filtered.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filtered.value = all;
      return;
    }

    filtered.value = all.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.nameBn.toLowerCase().contains(q) ||
          u.upazila.toLowerCase().contains(q) ||
          u.upazilaBn.toLowerCase().contains(q) ||
          u.district.toLowerCase().contains(q) ||
          u.districtBn.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Resolves the chosen union through the weather API (the JSON list only
  /// supplies the lat/lon + a fallback name — district/upazila/division come
  /// from the API, matching BMD), persists it as the active location, and
  /// lands on Home.
  Future<void> handleLocationSelection(UnionRecord item) async {
    isSaving.value = true;
    try {
      final isBangla = Get.locale?.languageCode == 'bn';
      final fetched = await userService.fetchLocationDetailsFromApi(
        lat: item.lat,
        lon: item.lng,
        displayNameFallback:
            item.upazila.isEmpty ? item.name : '${item.name}, ${item.upazila}',
        displayNameFallbackBn: item.upazilaBn.isEmpty
            ? item.nameBn
            : '${item.nameBn}, ${item.upazilaBn}',
        pcodeOverride: item.pcode,
      );
      if (fetched != null) {
        await userService.setFollowGPS(false); // manual pick — stop auto-following GPS
        await userService.saveSelectedLocation(fetched, isBangla: isBangla);
        Get.offAll(() => destination == LocationGateDestination.login
            ? const LoginPage()
            : const HomePage());
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
