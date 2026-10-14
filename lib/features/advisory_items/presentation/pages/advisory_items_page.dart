import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../advisory_stages/domen/binding/advisory_stages_binding.dart';
import '../../../advisory_stages/presentation/pages/advisory_stages_page.dart';
import '../../domen/controllers/advisory_items_controller.dart';

class AdvisoryItemsPage extends StatelessWidget {
  const AdvisoryItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvisoryItemsController>();
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
                      controller.categoryLabel ?? 'advisory_items.select_item_title'.tr,
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
                            onPressed: controller.loadItems,
                            child: Text('advisory_items.retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = controller.items;
                if (items.isEmpty) {
                  final label = controller.categoryLabel;
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
                      onTap: () => Get.to(
                        () => const AdvisoryStagesPage(),
                        binding: AdvisoryStagesBinding(
                          categoryId: controller.categoryId,
                          item: item,
                          categoryLabel: controller.categoryLabel,
                        ),
                      ),
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
