import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/network_controller.dart';
import '../../../../core/services/advisory_categories_service.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../models/advisory_item_model.dart';
import '../../../../models/user_choice_model.dart';
import '../../../advisory_stages/domen/binding/advisory_stages_binding.dart';
import '../../../advisory_stages/presentation/pages/advisory_stages_page.dart';

/// [UserChoiceModel] only carries a bare `categoryId`, not the category's
/// `isDisease` flag — resolve it against the cached catalog.
bool _isDiseaseCategory(int categoryId) =>
    AdvisoryCategoriesService().cached?.firstWhereOrNull((c) => c.id == categoryId)?.isDisease ??
    false;

class MyChoiceCarousel extends StatelessWidget {
  const MyChoiceCarousel({super.key, required this.items, this.onSeeAll});

  final List<UserChoiceModel> items;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final isBn = Get.locale?.languageCode == 'bn';
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: FigmaColors.neutralWhite,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'home.my_choice'.tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.primaryDefault,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: FigmaColors.neutralBackground,
                    border: Border.all(color: FigmaColors.primaryDefault),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'home.see_all'.tr,
                        style: TextStyle(fontSize: 14.sp, color: FigmaColors.primaryDefault),
                      ),
                      SizedBox(width: 4.w),
                      SvgPicture.asset(
                        'assets/icons/svg/arrow_double.svg',
                        width: 14.w,
                        height: 14.h,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            _EmptyMyChoice(onTap: onSeeAll)
          else
            SizedBox(
              height: 130.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, i) => _MyChoiceTile(choice: items[i], isBn: isBn),
              ),
            ),
        ],
      ),
    );
  }
}


class _EmptyMyChoice extends StatelessWidget {
  const _EmptyMyChoice({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.cardMint,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, size: 28.sp, color: AppColors.primaryDark),
            SizedBox(height: 8.h),
            Text(
              'my_choice.empty_home'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyChoiceTile extends StatelessWidget {
  const _MyChoiceTile({required this.choice, required this.isBn});

  final UserChoiceModel choice;
  final bool isBn;

  void _openStages() {
    final item = AdvisoryItemModel(
      id: choice.itemId,
      categoryId: choice.categoryId,
      name: choice.itemName,
      nameBn: choice.itemNameBn,
      imageUrl: choice.itemImageUrl,
    );
    Get.to(
      () => const AdvisoryStagesPage(),
      binding: AdvisoryStagesBinding(
        categoryId: choice.categoryId,
        item: item,
        categoryLabel: choice.categoryLabel(isBn),
        stageCategory: _isDiseaseCategory(choice.categoryId) ? 'disease' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openStages,
      child: Container(
        width: 125.w,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: FigmaColors.primaryTint,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MyChoiceIcon(imageUrl: choice.itemImageUrl),
            SizedBox(height: 12.h),
            Text(
              choice.itemLabel(isBn),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: FigmaColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyChoiceIcon extends StatelessWidget {
  const _MyChoiceIcon({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {

    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return Icon(Icons.eco, size: 36.sp, color: AppColors.primary);
    }

    return Obx(() {
      final epoch = Get.isRegistered<NetworkController>()
          ? Get.find<NetworkController>().reconnectedAt.value
          : 0;
      return Image.network(
        '${ApiEndpoints.baseUrlUserHost}$url',
        key: ValueKey('my_choice_icon_${url}_$epoch'),
        width: 48.w,
        height: 48.h,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image_outlined, size: 36.sp, color: AppColors.primary),
      );
    });
  }
}
