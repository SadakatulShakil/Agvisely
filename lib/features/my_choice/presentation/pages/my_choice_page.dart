import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/fade_network_image.dart';
import '../../../../core/utils/mordern_dropdown.dart';
import '../../../../models/user_choice_model.dart';
import '../../../auth/auth/presentation/widgets/auth_widgets.dart';
import '../../domen/controllers/my_choice_controller.dart';

/// to pick a category then an item (nothing pre-selected) and POSTs it.
class MyChoicePage extends StatelessWidget {
  const MyChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyChoiceController>();
    final isBn = Get.locale?.languageCode == 'bn';

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: SvgPicture.asset(
                    'assets/icons/svg/arrow_back.svg',
                    width: 30.w,
                    height: 30.h,
                  ),
                ),
                Text(
                  'home.my_choice'.tr,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w400,
                    color: FigmaColors.primaryDefault,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final error = controller.errorMessage.value;
                if (error != null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 36.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed: controller.loadChoices,
                            child: Text('common.retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final choices = controller.choices;
                return RefreshIndicator(
                  onRefresh: controller.loadChoices,
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 1.00,
                    ),
                    itemCount:
                        choices.length + 1, // + the "Add new" tile, always last
                    itemBuilder: (context, index) {
                      if (index == choices.length) {
                        return _AddNewTile(
                          onTap: () => _openAddSheet(controller),
                        );
                      }
                      final choice = choices[index];
                      return _ChoiceTile(
                        choice: choice,
                        isBn: isBn,
                        onRemove:
                            () => _confirmAndRemove(controller, choice, isBn),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndRemove(
    MyChoiceController controller,
    UserChoiceModel choice,
    bool isBn,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('my_choice.remove'.tr),
        content: Text(
          'my_choice.remove_confirm'.trParams({'item': choice.itemLabel(isBn)}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'my_choice.remove'.tr,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final error = await controller.removeChoice(choice);
    if (error != null) {
      Get.snackbar('my_choice.remove_failed'.tr, error);
    }
  }

  Future<void> _openAddSheet(MyChoiceController controller) async {
    controller.resetAddForm();
    await Get.bottomSheet(
      _AddChoiceSheet(controller: controller),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.choice,
    required this.isBn,
    required this.onRemove,
  });

  final UserChoiceModel choice;
  final bool isBn;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark.withValues(alpha: 0.0),
                AppColors.primaryDark.withValues(alpha: 0.06),
                AppColors.primaryDark.withValues(alpha: 0.30),
              ],
              stops: const [0.0, 0.46, 1.0],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChoiceIcon(imageUrl: choice.itemImageUrl),
              SizedBox(height: 10.h),
              Text(
                choice.itemLabel(isBn),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: FigmaColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 1.h,
          right: 5.w,
          child: GestureDetector(
            onTap: onRemove,
            child: SvgPicture.asset(
              'assets/icons/svg/cancel_icon.svg',
              width: 24.w,
              height: 24.h,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceIcon extends StatelessWidget {
  const _ChoiceIcon({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.eco, size: 36.sp, color: AppColors.primary);
    final url = imageUrl;
    return FadeNetworkImage(
      url:
          url == null || url.isEmpty
              ? null
              : '${ApiEndpoints.baseUrlUserHost}$url',
      width: 55.w,
      height: 55.h,
      fit: BoxFit.contain,
      placeholder: fallback,
    );
  }
}

class _AddNewTile extends StatelessWidget {
  const _AddNewTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark.withValues(alpha: 0.0),
              AppColors.primaryDark.withValues(alpha: 0.06),
              AppColors.primaryDark.withValues(alpha: 0.30),
            ],
            stops: const [0.0, 0.46, 1.0],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32.sp, color: AppColors.primaryDark),
            SizedBox(height: 10.h),
            Text(
              'my_choice.add_new'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: FigmaColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "Add new" sheet — category then item dropdowns, nothing pre-selected.
class _AddChoiceSheet extends StatelessWidget {
  const _AddChoiceSheet({required this.controller});

  final MyChoiceController controller;

  @override
  Widget build(BuildContext context) {
    final isBn = Get.locale?.languageCode == 'bn';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        child: SingleChildScrollView(
          // Dropdown popups need comfortable room to open in — a tightly
          // content-sized sheet feels cramped. Floors the sheet at just
          // over half the screen even when the form itself is shorter.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height * 0.55,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'my_choice.add_new_title'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'my_choice.add_new_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 16.h),

                FieldLabel('my_choice.category'.tr),
                Obx(() {
                  if (controller.categoriesLoading.value &&
                      controller.categories.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        value: controller.selectedCategory.value?.id,
                        isExpanded: true,
                        borderRadius: premiumDropdownRadius,
                        dropdownColor: premiumDropdownColor,
                        elevation: premiumDropdownElevation,
                        hint: Text(
                          'my_choice.select_category'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        decoration: agFieldDecoration('').copyWith(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        items:
                            controller.categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: premiumDropdownItemLabel(
                                      c.label(isBn),
                                      selected:
                                          c.id ==
                                          controller.selectedCategory.value?.id,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        // The closed field renders whichever of these lines up
                        // with the current value — the plain styled items
                        // above are for the open popup only. Without this, the
                        // selected value never shows in the closed field.
                        selectedItemBuilder:
                            (context) =>
                                controller.categories
                                    .map(
                                      (c) => Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          c.label(isBn),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                        onChanged: (id) {
                          final category = controller.categories
                              .firstWhereOrNull((c) => c.id == id);
                          controller.onCategoryChanged(category);
                        },
                      ),
                      if (controller.categoriesLoadFailed.value)
                        TextButton(
                          onPressed: controller.loadCategories,
                          child: Text('common.retry'.tr),
                        ),
                    ],
                  );
                }),

                SizedBox(height: 12.h),
                FieldLabel('my_choice.item'.tr),
                Obx(() {
                  final category = controller.selectedCategory.value;
                  if (category == null) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        'my_choice.select_category_first'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  }
                  if (controller.itemsLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        value: controller.selectedItem.value?.id,
                        isExpanded: true,
                        borderRadius: premiumDropdownRadius,
                        dropdownColor: premiumDropdownColor,
                        elevation: premiumDropdownElevation,
                        hint: Text(
                          'my_choice.select_item'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        decoration: agFieldDecoration('').copyWith(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        items:
                            controller.items
                                .map(
                                  (i) => DropdownMenuItem(
                                    value: i.id,
                                    child: premiumDropdownItemLabel(
                                      i.label(isBn),
                                      selected:
                                          i.id ==
                                          controller.selectedItem.value?.id,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        selectedItemBuilder:
                            (context) =>
                                controller.items
                                    .map(
                                      (i) => Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          i.label(isBn),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                        onChanged:
                            (id) =>
                                controller.selectedItem.value = controller.items
                                    .firstWhereOrNull((i) => i.id == id),
                      ),
                      if (controller.itemsLoadFailed.value)
                        TextButton(
                          onPressed:
                              () => controller.onCategoryChanged(category),
                          child: Text('common.retry'.tr),
                        ),
                    ],
                  );
                }),

                SizedBox(height: 28.h),
                Obx(
                  () => AgButton(
                    label: 'my_choice.add_button'.tr,
                    loading: controller.isSubmitting.value,
                    showArrow: false,
                    onPressed: () async {
                      final result = await controller.submitAddChoice();
                      if (result.duplicate) {
                        Get.snackbar(
                          'my_choice.already_added_title'.tr,
                          'my_choice.already_added'.tr,
                        );
                      } else if (result.error == null) {
                        Get.back();
                        Get.snackbar('', 'my_choice.add_success'.tr);
                      } else {
                        Get.snackbar('my_choice.add_failed'.tr, result.error!);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
