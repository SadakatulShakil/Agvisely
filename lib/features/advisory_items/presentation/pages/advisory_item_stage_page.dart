import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../models/advisory_item_model.dart';

/// Opened after "Go Next Step" on [AdvisoryItemsPage] — placeholder
/// scaffold for the selected item's advisory stage flow. Build the real UI
/// here once that Figma frame exists.
class AdvisoryItemStagePage extends StatelessWidget {
  const AdvisoryItemStagePage({super.key, required this.item});

  final AdvisoryItemModel item;

  @override
  Widget build(BuildContext context) {
    final isBn = Get.locale?.languageCode == 'bn';
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          item.label(isBn),
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Center(
        child: Text(
          '${item.label(isBn)} — TODO from Figma',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}
