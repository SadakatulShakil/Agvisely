import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/empty_state_widget.dart';
import '../../domen/controllers/location_pick_controller.dart';
import '../../models/location_gate_destination.dart';

class SelectLocationPage extends StatelessWidget {
  final bool isFirstInstall;
  final LocationGateDestination destination;
  SelectLocationPage({
    super.key,
    this.isFirstInstall = false,
    this.destination = LocationGateDestination.home,
  });
  final controller = Get.find<SelectLocationController>();
  final isBangla = Get.locale?.languageCode == 'bn';

  @override
  Widget build(BuildContext context) {
    controller.destination = destination;
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: Stack(
        children: [
          _buildBody(),
          Obx(
            () =>
                controller.isSaving.value
                    ? Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 20.h, 16.w, 8.h),
            child: Row(
              children: [
                if (!isFirstInstall)
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/svg/arrow_back.svg',
                      width: 24.w,
                      height: 24.h,
                    ),
                    onPressed: () => Get.back(),
                  )
                else
                  SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    'select_location.title'.tr,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w400,
                      color: FigmaColors.primaryDefault,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: FigmaColors.neutralBorder),
              ),
              child: TextField(
                controller: controller.searchController,
                textInputAction: TextInputAction.search,
                onChanged: controller.search,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'select_location.search_hint'.tr,
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    color: FigmaColors.neutralPlaceholder,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    size: 22.sp,
                    color: FigmaColors.primaryDefault,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filtered.isEmpty) {
                return EmptyStateWidget(
                  message: 'select_location.no_results'.tr,
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                itemCount: controller.filtered.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = controller.filtered[index];
                  return InkWell(
                    onTap:
                        () =>
                            isFirstInstall
                                ? controller.handleLocationSelection(item)
                                : Get.back(result: item),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardLight,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isBangla ? item.nameBn : item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: FigmaColors.primaryDark,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  isBangla ? item.districtBn : item.district,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: FigmaColors.neutralSecondary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '(${item.lat.toStringAsFixed(5)}, ${item.lng.toStringAsFixed(5)})',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: FigmaColors.primaryDefault,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            color: FigmaColors.primaryDefault,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
