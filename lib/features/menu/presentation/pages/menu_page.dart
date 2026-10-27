import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: 'assets/images/barc_logo.png', label: 'menu.barc_fertilizer'.tr),
      (icon: 'assets/images/ipm_logo.png', label: 'menu.ipm_booklist'.tr),
      (icon: 'assets/images/feedback_logo.png', label: 'menu.user_feedback'.tr),
      (icon: 'assets/images/other_logo.png', label: 'menu.other_apps'.tr),
    ];

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 10.h),
        children: [
          Text(
            'menu.title'.tr,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w400,
              color: FigmaColors.primaryDefault,
            ),
          ),
          SizedBox(height: 20.h),
          for (final item in items) ...[
            _MenuItemRow(icon: item.icon, label: item.label, onTap: () {}),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  const _MenuItemRow({required this.icon, required this.label, this.onTap});

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 45.w,
              height: 45.w,
              child: Image.asset(icon, width: 24.w, height: 24.w)
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: FigmaColors.primaryDark,
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/svg/arrow_right.svg',
              width: 24.w,
              height: 24.w,
            ),
          ],
        ),
      ),
    );
  }
}
