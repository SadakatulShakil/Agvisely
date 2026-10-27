import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/network_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';

class AdvisoryCard extends StatelessWidget {
  const AdvisoryCard({
    super.key,
    required this.iconUrl,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String? iconUrl;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  Widget _fallbackIcon() => Icon(Icons.info_outline, size: 40.sp, color: iconColor);

  Widget _icon() {
    final url = iconUrl;
    if (url == null || url.isEmpty) return _fallbackIcon();

    return Obx(() {
      final epoch = Get.isRegistered<NetworkController>()
          ? Get.find<NetworkController>().reconnectedAt.value
          : 0;
      return Image.network(
        '${ApiEndpoints.baseUrlUserHost}$url',
        key: ValueKey('advisory_icon_${url}_$epoch'),
        width: 56.w,
        height: 56.h,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image_outlined, size: 40.sp, color: iconColor),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final icon = _icon();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                SvgPicture.asset(
                  'assets/icons/svg/arrow_up_right.svg',
                  width: 24.w,
                  height: 24.h,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: FigmaColors.primaryDark,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: FigmaColors.neutralBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
