import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';

/// One item in the "My Choice" horizontal carousel.
class MyChoiceItem {
  const MyChoiceItem({required this.icon, required this.label});

  /// PNG asset path — these Figma exports are a shape with a raster
  /// "image fill" wrapped in an SVG `<pattern>`, which flutter_svg's
  /// renderer doesn't support (renders blank). Use the real PNG instead.
  final String icon;
  final String label;
}

/// Header ("My Choice" + "See all") + horizontally-scrollable carousel of
/// the farmer's chosen crops/livestock. Demo data for now — swap [items]
/// for the real "My Choice" payload once that endpoint exists.
class MyChoiceCarousel extends StatelessWidget {
  const MyChoiceCarousel({super.key, required this.items, this.onSeeAll});

  final List<MyChoiceItem> items;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
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
          SizedBox(
            height: 130.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, i) => _MyChoiceTile(item: items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyChoiceTile extends StatelessWidget {
  const _MyChoiceTile({required this.item});

  final MyChoiceItem item;

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
          Image.asset(
            item.icon,
            width: 48.w,
            height: 48.h,
          ),
          SizedBox(height: 12.h),
          Text(
            item.label,
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
