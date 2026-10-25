import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/auth/presentation/widgets/auth_widgets.dart';
import '../../../advisory_stages/domen/binding/advisory_stages_binding.dart';
import '../../../advisory_stages/presentation/pages/advisory_stages_page.dart';
import '../../domen/controllers/advisory_disease_items_controller.dart';

/// "Crop Disease Early Warning" — a category dropdown (crop, livestock,
/// aquaculture, ...) over an item grid for whichever one is selected.
/// Picking an item proceeds exactly like the other advisory categories.
class AdvisoryDiseaseItemsPage extends StatelessWidget {
  const AdvisoryDiseaseItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvisoryDiseaseItemsController>();
    final isBn = Get.locale?.languageCode == 'bn';

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 20.h, 16.w, 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      'advisory_items.disease_title'.tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FieldLabel('advisory_items.select_category_label'.tr),
                  Obx(() {
                    if (controller.categoriesLoading.value && controller.categories.isEmpty) {
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
                          decoration: agFieldDecoration('').copyWith(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          ),
                          items: controller.categories
                              .map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      c.label(isBn),
                                      style: TextStyle(
                                          fontSize: 16.sp, color: AppColors.textSecondaryLight),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (id) {
                            final category =
                                controller.categories.firstWhereOrNull((c) => c.id == id);
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
                ],
              ),
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
                          Icon(Icons.wifi_off_rounded, size: 36.sp, color: AppColors.textSecondaryLight),
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
                            onPressed: () => controller.onCategoryChanged(controller.selectedCategory.value),
                            child: Text('advisory_items.retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = controller.items;
                if (items.isEmpty) {
                  final label = controller.selectedCategory.value?.label(isBn);
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        label == null
                            ? 'advisory_items.empty'.tr
                            : 'advisory_items.empty_for'.trParams({'category': label}),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return GestureDetector(
                      onTap: () {
                        final category = controller.selectedCategory.value;
                        if (category == null) return;
                        Get.to(
                          () => const AdvisoryStagesPage(),
                          binding: AdvisoryStagesBinding(
                            categoryId: category.id,
                            item: item,
                            categoryLabel: category.label(isBn),
                            stageCategory: 'disease',
                          ),
                        );
                      },
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
                            _ItemIcon(imageUrl: item.imageUrl),
                            SizedBox(height: 10.h),
                            Text(
                              item.label(isBn),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13.sp, color: AppColors.navy),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid tile icon — the item's `imageUrl` when present, else a leaf fallback.
class _ItemIcon extends StatelessWidget {
  const _ItemIcon({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.eco, size: 36.sp, color: AppColors.primary);
    final url = imageUrl;
    if (url == null || url.isEmpty) return fallback;
    return Image.network(
      '${ApiEndpoints.baseUrlUserHost}$url',
      width: 55.w,
      height: 55.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
