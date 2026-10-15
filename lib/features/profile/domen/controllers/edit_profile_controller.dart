import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/professions_service.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../models/profession_model.dart';
import 'profile_controller.dart';

/// Edit-profile screen state. Name and profession are seeded from the
/// already-loaded [ProfileController] (no extra fetch needed), and only the
/// fields the user actually changed are sent to `PUT /users/me` — name and
/// profession are independently optional there.
class EditProfileController extends GetxController {
  late final TextEditingController nameController;

  final professions = <ProfessionModel>[].obs;
  final selectedProfession = Rxn<ProfessionModel>();
  final professionsLoading = false.obs;
  final professionsLoadFailed = false.obs;
  final isSubmitting = false.obs;
  final isUploadingPicture = false.obs;
  /// Set immediately on pick, shown via BoxFit.cover so the avatar reflects
  /// the user's choice right away instead of sitting on the stale server
  /// image until the upload round-trips. Cleared on failure (the picture
  /// didn't actually change, so revert to what's really on the server).
  final pickedImagePath = Rxn<String>();

  String? _initialName;
  int? _initialProfessionId;

  ProfileController get _profile => Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    final user = _profile.user.value;
    _initialName = user?.name;
    _initialProfessionId = user?.professionId;
    nameController = TextEditingController(text: user?.name ?? '');
    selectedProfession.value = _profile.profession.value;
    loadProfessions();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> loadProfessions() async {
    professionsLoading.value = true;
    professionsLoadFailed.value = false;

    final cached = ProfessionsService().cached;
    if (cached != null) {
      professions.assignAll(cached);
      _reselectCurrentProfession();
    }

    final fresh = await ProfessionsService().fetch();
    if (fresh != null) {
      professions.assignAll(fresh);
      _reselectCurrentProfession();
    } else if (cached == null) {
      professionsLoadFailed.value = true;
    }
    professionsLoading.value = false;
  }

  void _reselectCurrentProfession() {
    if (selectedProfession.value != null) return;
    selectedProfession.value =
        professions.firstWhereOrNull((p) => p.id == _initialProfessionId);
  }

  /// Returns a user-facing error message on failure, or null on success.
  Future<String?> save() async {
    final trimmedName = nameController.text.trim();
    final nameChanged = trimmedName.isNotEmpty && trimmedName != _initialName;
    final professionChanged =
        selectedProfession.value != null && selectedProfession.value!.id != _initialProfessionId;

    if (!nameChanged && !professionChanged) return null; // nothing to do

    isSubmitting.value = true;
    try {
      final updated = await UserPrefService().updateProfile(
        name: nameChanged ? trimmedName : null,
        professionId: professionChanged ? selectedProfession.value!.id : null,
      );
      if (updated != null) {
        _profile.applyUser(updated);
        _initialName = updated.name;
        _initialProfessionId = updated.professionId;
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Returns a user-facing error message on failure, or null on success
  /// (including the no-op case where the user cancelled the picker).
  Future<String?> pickAndUploadPicture(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return null;

    pickedImagePath.value = picked.path;
    isUploadingPicture.value = true;
    try {
      final updated = await UserPrefService().uploadProfilePicture(File(picked.path));
      if (updated != null) _profile.applyUser(updated);
      return null;
    } catch (e) {
      pickedImagePath.value = null; // revert to the real (unchanged) server image
      return e.toString();
    } finally {
      isUploadingPicture.value = false;
    }
  }
}
