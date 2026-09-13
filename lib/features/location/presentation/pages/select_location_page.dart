import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domen/controllers/location_pick_controller.dart';

class SelectLocationPage extends StatelessWidget {
  final bool isFirstInstall;
  SelectLocationPage({super.key, this.isFirstInstall = false});
  final controller = Get.find<SelectLocationController>();
  final isBangla = Get.locale?.languageCode == 'bn';

  String _stepTitle(PickStep step) {
    switch (step) {
      case PickStep.district:
        return isBangla ? 'জেলা নির্বাচন করুন' : 'Select District';
      case PickStep.upazila:
        return isBangla ? 'উপজেলা নির্বাচন করুন' : 'Select Upazila';
      case PickStep.union:
        return isBangla ? 'ইউনিয়ন নির্বাচন করুন' : 'Select Union';
    }
  }

  String _searchHint(PickStep step) {
    switch (step) {
      case PickStep.district:
        return isBangla ? 'জেলা খুঁজুন...' : 'Search district...';
      case PickStep.upazila:
        return isBangla ? 'উপজেলা খুঁজুন...' : 'Search upazila...';
      case PickStep.union:
        return isBangla ? 'ইউনিয়ন খুঁজুন...' : 'Search union...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              Obx(
                () => Container(
                  padding: EdgeInsets.fromLTRB(8.w, 50.h, 16.w, 16.h),
                  height: 150.h,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isFirstInstall || controller.step.value != PickStep.district)
                        GestureDetector(
                          onTap: () => controller.step.value == PickStep.district
                              ? Get.back()
                              : controller.back(),
                          child: Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.only(left: 15.w, top: 11.h, bottom: 12.h),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _stepTitle(controller.step.value),
                                style: AppFonts.style(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  letterSpacing: 0.3.sp,
                                ),
                              ),
                              if (controller.selectedDistrict.value != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Text(
                                    [
                                      if (controller.selectedDistrict.value != null)
                                        isBangla
                                            ? controller.selectedDistrict.value!.nameBn
                                            : controller.selectedDistrict.value!.name,
                                      if (controller.selectedUpazila.value != null)
                                        isBangla
                                            ? controller.selectedUpazila.value!.nameBn
                                            : controller.selectedUpazila.value!.name,
                                    ].join(' › '),
                                    style: AppFonts.style(
                                      fontSize: 12.sp,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content
              Positioned(
                top: 100.h,
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.r),
                    topLeft: Radius.circular(16.r),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.r,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar
                          Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withValues(alpha: 0.05),
                                    blurRadius: 4.r,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                key: ValueKey(controller.step.value),
                                controller: controller.searchController,
                                textInputAction: TextInputAction.search,
                                onChanged: controller.search,
                                style: AppFonts.style(
                                  color: Colors.black87,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  hintText: _searchHint(controller.step.value),
                                  hintStyle: AppFonts.style(
                                    color: Colors.grey,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  suffixIcon: Icon(Icons.search, size: 22.sp),
                                  suffixIconColor: AppColors.primary,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          Expanded(
                            child: Obx(() {
                              if (controller.isLoading.value) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              switch (controller.step.value) {
                                case PickStep.district:
                                  return _list(
                                    count: controller.filteredDistricts.length,
                                    itemBuilder: (i) {
                                      final d = controller.filteredDistricts[i];
                                      return _tile(
                                        title: isBangla ? d.nameBn : d.name,
                                        subtitle: null,
                                        trailing: Icons.chevron_right,
                                        onTap: () => controller.selectDistrict(d),
                                      );
                                    },
                                  );
                                case PickStep.upazila:
                                  return _list(
                                    count: controller.filteredUpazilas.length,
                                    itemBuilder: (i) {
                                      final u = controller.filteredUpazilas[i];
                                      return _tile(
                                        title: isBangla ? u.nameBn : u.name,
                                        subtitle: null,
                                        trailing: Icons.chevron_right,
                                        onTap: () => controller.selectUpazila(u),
                                      );
                                    },
                                  );
                                case PickStep.union:
                                  return _list(
                                    count: controller.filteredUnions.length,
                                    itemBuilder: (i) {
                                      final u = controller.filteredUnions[i];
                                      return _tile(
                                        title: isBangla ? u.nameBn : u.name,
                                        subtitle:
                                            '(${u.lat.toStringAsFixed(5)}, ${u.lng.toStringAsFixed(5)})',
                                        trailing: Icons.location_on,
                                        onTap: () => isFirstInstall
                                            ? controller.handleLocationSelection(u)
                                            : Get.back(result: u),
                                      );
                                    },
                                  );
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Obx(
                () => controller.isSaving.value
                    ? Container(
                        color: Colors.black26,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list({required int count, required Widget Function(int) itemBuilder}) {
    if (count == 0) {
      return Center(
        child: Text(
          isBangla ? "কোন ফলাফল পাওয়া যায়নি" : "No results found",
          style: AppFonts.style(color: Colors.black54, fontSize: 16.sp),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(top: 5.h),
      itemCount: count,
      itemBuilder: (context, i) => itemBuilder(i),
    );
  }

  Widget _tile({
    required String title,
    required String? subtitle,
    required IconData trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        title: Text(
          title,
          style: AppFonts.style(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: AppFonts.style(fontSize: 14.sp, color: Colors.black54),
              ),
        trailing: Icon(trailing, color: AppColors.primary, size: 20.sp),
        onTap: onTap,
      ),
    );
  }
}
