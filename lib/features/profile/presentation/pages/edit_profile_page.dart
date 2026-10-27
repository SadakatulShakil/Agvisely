import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/user_avatar.dart';
import '../../../auth/auth/presentation/widgets/auth_widgets.dart';
import '../../domen/controllers/edit_profile_controller.dart';
import '../../domen/controllers/profile_controller.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EditProfileController());

    return Scaffold(
      body: SageBackground(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: SvgPicture.asset('assets/icons/svg/arrow_back.svg', width: 24.w, height: 24.h),
                  ),
                  Text(
                    'profile.edit_profile'.tr,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w400,
                      color: FigmaColors.primaryDefault,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    Center(
                      child: GestureDetector(
                        onTap: () => _showPictureSourceSheet(c),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Obx(() {
                              final pickedPath = c.pickedImagePath.value;
                              if (pickedPath != null) {
                                return Container(
                                  width: 160.w,
                                  height: 160.w,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 0),
                                  ),
                                  child: Image.file(
                                    File(pickedPath),
                                    width: 160.w,
                                    height: 160.w,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              return UserAvatar(
                                profileUrl: Get.find<ProfileController>().user.value?.profileUrl,
                                size: 160.w,
                                iconSize: 115.sp,
                                border: Border.all(color: Colors.white, width: 0),
                              );
                            }),
                            Obx(
                              () => c.isUploadingPicture.value
                                  ? Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 5,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: FigmaColors.primaryDefault,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: FigmaColors.neutralWhite, width: 2),
                                ),
                                child: Icon(Icons.camera_alt, size: 20.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    FieldLabel('profile.name'.tr),
                    TextField(
                      controller: c.nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: agFieldDecoration('profile.name'.tr).copyWith(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    FieldLabel('profile.profession'.tr),
                    Obx(() {
                      if (c.professionsLoading.value && c.professions.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final isBn = Get.locale?.languageCode == 'bn';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<int>(
                            value: c.selectedProfession.value?.id,
                            isExpanded: true,
                            hint: Text(
                              'profile.select_profession'.tr,
                              style: TextStyle(fontSize: 18.sp, color: AppColors.textSecondaryLight),
                            ),
                            decoration: agFieldDecoration('').copyWith(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            ),
                            icon: SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: SvgPicture.asset(
                                'assets/icons/svg/arrow_down.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                            iconSize: 18.w,
                            items: c.professions
                                .map((p) => DropdownMenuItem(
                                      value: p.id,
                                      child: Text(
                                        p.label(isBn),
                                        style: TextStyle(
                                            fontSize: 18.sp, color: AppColors.textSecondaryLight),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (id) => c.selectedProfession.value =
                                c.professions.firstWhereOrNull((p) => p.id == id),
                          ),
                          if (c.professionsLoadFailed.value)
                            TextButton(
                              onPressed: c.loadProfessions,
                              child: Text('common.retry'.tr),
                            ),
                        ],
                      );
                    }),

                    SizedBox(height: 32.h),
                    Obx(() => AgButton(
                          label: 'common.save'.tr,
                          loading: c.isSubmitting.value,
                          showArrow: false,
                          onPressed: () async {
                            final error = await c.save();
                            if (error == null) {
                              Get.back();
                              Get.snackbar('', 'profile.update_success'.tr);
                            } else {
                              Get.snackbar('profile.update_failed'.tr, error);
                            }
                          },
                        )),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPictureSourceSheet(EditProfileController c) async {
    final source = await Get.bottomSheet<ImageSource>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('profile.take_photo'.tr),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('profile.choose_from_gallery'.tr),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
    );
    if (source == null) return;

    final error = await c.pickAndUploadPicture(source);
    if (error == null) {
      Get.snackbar('', 'profile.picture_update_success'.tr);
    } else {
      Get.snackbar('profile.picture_update_failed'.tr, error);
    }
  }
}
