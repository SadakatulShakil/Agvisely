import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../models/advisory_item_model.dart';
import '../../../../models/advisory_stage_model.dart';

/// Opened after "See The Advisory" on [AdvisoryStagesPage] — placeholder
/// scaffold for the actual advisory content. Build the real UI here once
/// that Figma frame exists.
class AdvisoryContentPage extends StatelessWidget {
  const AdvisoryContentPage({super.key, required this.item, required this.stage});

  final AdvisoryItemModel item;
  final AdvisoryStageModel stage;

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
          stage.label(isBn),
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Center(
        child: Text(
          '${item.label(isBn)} · ${stage.label(isBn)} — TODO from Figma',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}
