import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domen/binding/advisory_content_binding.dart';
import '../../domen/controllers/advisory_stages_controller.dart';
import 'advisory_content_page.dart';

// Backend category ids (see agvisely-backend's advisory_categories seed).
const _cropCategoryId = 1;
const _livestockCategoryId = 2;
const _aquacultureCategoryId = 3;

/// Fixed per-category title, matching the approved copy exactly; the disease
/// flow (flagged via [AdvisoryStagesController.stageCategory]) and any other
/// (future) category id fall back to a generic, category-label-driven title.
String _stageListTitle(AdvisoryStagesController controller, bool isBn) {
  if (controller.stageCategory == 'disease') {
    return 'advisory_stages.disease_title_for'
        .trParams({'item': controller.item.label(isBn)});
  }
  switch (controller.categoryId) {
    case _cropCategoryId:
      return 'advisory_stages.title_crop'.tr;
    case _livestockCategoryId:
      return 'advisory_stages.title_livestock'.tr;
    case _aquacultureCategoryId:
      return 'advisory_stages.title_aquaculture'.tr;
    default:
      return controller.categoryLabel != null
          ? 'advisory_stages.select_stage_title_for'
              .trParams({'category': controller.categoryLabel!})
          : 'advisory_stages.select_stage_title'.tr;
  }
}

/// "Select a stage for advisory" — per the "Crop advisory" Figma frame:
/// a header card for the picked item, then a scrollable list of its stages
/// (thumbnail + name + description); tapping a stage goes straight to its
/// advisory content. One page, reused by every advisory category/item.
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
                    icon: SvgPicture.asset('assets/icons/svg/arrow_back.svg', width: 24.w, height: 24.h),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      _stageListTitle(controller, isBn),
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
                    final description = stage.descriptionLabel(isBn);
                    return GestureDetector(
                      onTap: () => Get.to(
                        () => const AdvisoryContentPage(),
                        binding: AdvisoryContentBinding(
                          categoryId: controller.categoryId,
                          categoryLabel: controller.categoryLabel,
                          item: controller.item,
                          stage: stage,
                          ipmOnly: controller.ipmOnly,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            _Thumbnail(imageUrl: stage.icon, size: 70.w),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stage.label(isBn),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  if (description.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      description,
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
