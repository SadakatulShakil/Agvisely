import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../home/domen/controllers/home_controller.dart';

class _CropOption {
  const _CropOption(this.emoji, this.labelKey);
  final String emoji;

  /// Localization key — resolved with `.tr` at render time.
  final String labelKey;
}

/// "Select a crop for advisory" — demo-only crop grid matching the Figma
/// frame. No real advisory content exists yet, so "Go Next Step" just
/// confirms the pick; tap targets have no destination page.
class PestAdvisoryPage extends StatefulWidget {
  const PestAdvisoryPage({super.key});

  @override
  State<PestAdvisoryPage> createState() => _PestAdvisoryPageState();
}

class _PestAdvisoryPageState extends State<PestAdvisoryPage> {
  // Demo data — deliberately repeats a few crops to match the Figma frame's
  // scrollable grid. Swap for the real crop-catalog list when it exists.
  static const _crops = [
    _CropOption('🍅', 'crop.tomato'),
    _CropOption('🌾', 'crop.kharif1'),
    _CropOption('🌽', 'crop.maize'),
    _CropOption('🌾', 'crop.kharif2'),
    _CropOption('🫘', 'crop.lentil'),
    _CropOption('🍅', 'crop.tomato'),
    _CropOption('🌽', 'crop.maize'),
    _CropOption('🌾', 'crop.wheat'),
    _CropOption('🫘', 'crop.lentil'),
    _CropOption('🌾', 'crop.rabi'),
    _CropOption('🌾', 'crop.wheat'),
    _CropOption('🥔', 'crop.potato'),
    _CropOption('🍌', 'crop.banana'),
    _CropOption('🌱', 'crop.mung_bean'),
    _CropOption('🍌', 'crop.banana'),
    _CropOption('🥔', 'crop.potato'),
    _CropOption('🍌', 'crop.banana'),
    _CropOption('🌱', 'crop.mung_bean'),
  ];

  int _selected = -1; // "Kharif 2" pre-selected, matching the Figma frame.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'pest_advisory.select_crop_title'.tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.85,
                ),
                itemCount: _crops.length,
                itemBuilder: (context, i) {
                  final crop = _crops[i];
                  final isSelected = i == _selected;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF678042).withValues(alpha: 0.0),
                            const Color(0xFF678042).withValues(alpha: 0.06),
                            const Color(0xFF678042).withValues(alpha: 0.40),
                          ],
                          stops: const [0.0, 0.50, 1.5],
                        ),
                        borderRadius: !isSelected
                            ?BorderRadius.only(
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        )
                        :BorderRadius.circular(16.r),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(crop.emoji, style: TextStyle(fontSize: 36.sp)),
                          SizedBox(height: 10.h),
                          Text(
                            crop.labelKey.tr,
                            style: TextStyle(fontSize: 13.sp, color: AppColors.navy),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: GestureDetector(
                onTap: () =>
                _selected != -1
                    ? Get.snackbar(
                  'Agvisely',
                  '${'pest_advisory.selected_prefix'.tr} ${_crops[_selected].labelKey.tr}',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(12.w),
                ): Get.snackbar(
                  'Agvisely',
                  'pest_advisory.nothing_prefix'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(12.w),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'pest_advisory.go_next_step'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18.sp),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
