import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domen/controllers/advisory_stages_controller.dart';
import 'advisory_content_page.dart';

/// "Select a stage for advisory" — per the "Crop advisory" Figma frame:
/// a header card for the picked item, then a scrollable list of its stages
/// (thumbnail + name + date range), then a "See The Advisory" CTA. One
/// page, reused by every advisory category/item.
class AdvisoryStagesPage extends StatelessWidget {
  const AdvisoryStagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvisoryStagesController>();
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
                      controller.categoryLabel != null
                          ? 'advisory_stages.select_stage_title_for'
                              .trParams({'category': controller.categoryLabel!})
                          : 'advisory_stages.select_stage_title'.tr,
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
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    _Thumbnail(imageUrl: controller.item.imageUrl, size: 44.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.item.label(isBn),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'advisory_stages.card_subtitle'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                            onPressed: controller.loadStages,
                            child: Text('advisory_stages.retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final stages = controller.stages;
                if (stages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'advisory_stages.empty_for'
                            .trParams({'item': controller.item.label(isBn)}),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                  itemCount: stages.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, i) {
                    final stage = stages[i];
                    final dateRange = stage.dateRangeLabel(isBn);
                    // ListView.builder's itemBuilder runs lazily, outside the
                    // outer Obx's synchronous build — reading selectedIndex
                    // out there would never register as a dependency, so
                    // each row tracks it with its own Obx instead.
                    return Obx(() {
                      final isSelected = i == controller.selectedIndex.value;
                      return GestureDetector(
                        onTap: () => controller.select(i),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppColors.cardLight,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              _Thumbnail(imageUrl: stage.imageUrl, size: 52.w),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stage.label(isBn),
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.navy,
                                      ),
                                    ),
                                    if (dateRange.isNotEmpty) ...[
                                      SizedBox(height: 4.h),
                                      Text(
                                        dateRange,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: GestureDetector(
                onTap: () {
                  final index = controller.selectedIndex.value;
                  if (index == -1) {
                    Get.snackbar(
                      'Agvisely',
                      'advisory_stages.nothing_selected'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: EdgeInsets.all(12.w),
                    );
                    return;
                  }
                  Get.to(
                    () => AdvisoryContentPage(
                      item: controller.item,
                      stage: controller.stages[index],
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'advisory_stages.see_advisory'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18.sp),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Square thumbnail — the given `imageUrl` when present, else a leaf fallback.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl, required this.size});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.eco, size: size * 0.55, color: AppColors.primary),
    );
    final url = imageUrl;
    if (url == null || url.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        '${ApiEndpoints.baseUrlUserHost}$url',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
