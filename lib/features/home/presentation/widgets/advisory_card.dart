import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';

/// One tile of the home dashboard's advisory grid — icon + external-link
/// arrow up top, bold title, then a two-line grey subtitle underneath.
class AdvisoryCard extends StatelessWidget {
  const AdvisoryCard({
    super.key,
    required this.iconUrl,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  /// Relative path from the advisory-categories API (e.g.
  /// `/assets/category/xxx.png`) — resolved against [ApiEndpoints.baseUrlUserHost].
  final String? iconUrl;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Icon(Icons.info_outline, size: 40.sp, color: iconColor);
    final url = iconUrl;
    final icon = (url == null || url.isEmpty)
        ? fallbackIcon
        : Image.network(
            '${ApiEndpoints.baseUrlUserHost}$url',
            width: 56.w,
            height: 56.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => fallbackIcon,
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                Icon(Icons.north_east, size: 24.sp, color: AppColors.primaryDark),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.3,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
