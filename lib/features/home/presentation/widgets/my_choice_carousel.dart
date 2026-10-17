import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../models/user_choice_model.dart';

/// Header ("My Choice" + "See all") + horizontally-scrollable carousel of
/// the farmer's saved picks from `GET /user-choices`. When [items] is
/// empty, shows a prompt to go pick some from the My Choice page instead
/// (tapping it fires [onSeeAll], same destination as the "See all" pill).
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
        color: AppColors.cardLight,
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
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryDark),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'home.see_all'.tr,
                        style: TextStyle(fontSize: 12.sp, color: AppColors.primaryDark),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.double_arrow, size: 14.sp, color: AppColors.primaryDark),
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

/// Shown instead of the carousel when the farmer hasn't picked anything yet
/// — nudges them to go add one from the My Choice page.
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.cardMint,
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
              fontWeight: FontWeight.w500,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyChoiceIcon extends StatelessWidget {
  const _MyChoiceIcon({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.eco, size: 36.sp, color: AppColors.primary);
    final url = imageUrl;
    if (url == null || url.isEmpty) return fallback;
    return Image.network(
      '${ApiEndpoints.baseUrlUserHost}$url',
      width: 48.w,
      height: 48.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
