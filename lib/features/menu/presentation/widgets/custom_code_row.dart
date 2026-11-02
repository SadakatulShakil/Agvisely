import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../models/custom_code_model.dart';

/// One row in the Menu tab's root list or a drill-down browser page —
/// [CustomCodeModel.iconUrl] (absolute, or relative to the API host) with a
/// generic fallback, the node's [CustomCodeModel.name], and a trailing
/// chevron.
class CustomCodeRow extends StatelessWidget {
  const CustomCodeRow({super.key, required this.node, required this.onTap});

  final CustomCodeModel node;
  final VoidCallback onTap;

  String? get _resolvedIconUrl {
    final iconUrl = node.iconUrl;
    if (iconUrl == null || iconUrl.isEmpty) return null;
    return iconUrl.startsWith('http') ? iconUrl : '${ApiEndpoints.baseUrlUserHost}$iconUrl';
  }

  @override
  Widget build(BuildContext context) {
    final iconUrl = _resolvedIconUrl;
    final fallback = Icon(Icons.apps_rounded, size: 22.sp, color: AppColors.primary);

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
              child: Center(
                child: iconUrl == null
                    ? fallback
                    : Image.network(
                        iconUrl,
                        width: 45.w,
                        height: 45.w,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => fallback,
                      ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                node.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.sp,
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
