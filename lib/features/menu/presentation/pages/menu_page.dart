import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';

/// "Menu items" screen — reached from the bottom-nav Menu tab, so no back
/// button (it's a tab, not a pushed route). Demo-only: rows have no
/// destination page yet, so their taps are no-ops.
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.science_outlined, label: 'menu.barc_fertilizer'.tr),
      (icon: Icons.menu_book_outlined, label: 'menu.ipm_booklist'.tr),
      (icon: Icons.feedback_outlined, label: 'menu.user_feedback'.tr),
      (icon: Icons.apps_outlined, label: 'menu.other_apps'.tr),
    ];

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Text(
            'menu.title'.tr,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
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

  final IconData icon;
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
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.cardMint,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 22.sp, color: AppColors.primaryDark),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.navy,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20.sp, color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}
