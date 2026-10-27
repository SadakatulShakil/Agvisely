import 'package:flutter/material.dart';

import '../network/api_endpoints.dart';
import '../theme/app_theme_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? profileUrl;
  final double size;
  final double iconSize;
  final BorderRadius? borderRadius; // null => circle
  final Border? border;

  const UserAvatar({
    super.key,
    required this.profileUrl,
    required this.size,
    required this.iconSize,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.person, size: iconSize, color: AppColors.primaryDark);
    final url = profileUrl;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        border: border,
      ),
      child: (url == null || url.isEmpty)
          ? Center(child: fallback)
          : Image.network(
              '${ApiEndpoints.baseUrlUserHost}$url',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(child: fallback),
            ),
    );
  }
}
