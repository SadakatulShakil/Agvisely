import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../domen/controllers/location_pick_controller.dart';

class SelectLocationPage extends StatelessWidget {
  final bool isFirstInstall;
  SelectLocationPage({super.key, this.isFirstInstall = false});
  final controller = Get.find<SelectLocationController>();
  final isBangla = Get.locale?.languageCode == 'bn';

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
              Container(
                padding: EdgeInsets.fromLTRB(8.w, 50.h, 16.w, 16.h),
                height: 150.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B8CBE), Color(0xFF09228F)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isFirstInstall)
                      GestureDetector(
                        onTap: () => Get.back(),
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
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        isBangla ? 'লোকেশন নির্বাচন করুন' : 'Select Location',
                        textAlign: TextAlign.center,
                        style: AppFonts.style(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                          color: Colors.white,
                          letterSpacing: 0.3.sp,
                        ),
                      ),
                    ),
                  ],
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
                          Container(
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
                              controller: controller.searchController,
                              textInputAction: TextInputAction.search,
                              onChanged: controller.search,
                              style: AppFonts.style(
                                color: Colors.black87,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintText: isBangla
                                    ? "উপজেলা বা জেলা খুঁজুন..."
                                    : "Search upazila or district...",
                                hintStyle: AppFonts.style(
                                  color: Colors.grey,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                suffixIcon: Icon(Icons.search, size: 22.sp),
                                suffixIconColor: const Color(0xFF1B8CBE),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
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

                              if (controller.filtered.isEmpty) {
                                return Center(
                                  child: Text(
                                    isBangla ? "কোন ফলাফল পাওয়া যায়নি" : "No results found",
                                    style: AppFonts.style(
                                      color: Colors.black54,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: EdgeInsets.only(top: 5.h),
                                itemCount: controller.filtered.length,
                                itemBuilder: (context, index) {
                                  final item = controller.filtered[index];
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 6.h),
                                      title: Text(
                                        isBangla ? item.nameBn : item.name,
                                        style: AppFonts.style(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isBangla ? item.districtBn : item.district,
                                            style: AppFonts.style(
                                              fontSize: 14.sp,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            '(${item.lat.toStringAsFixed(5)}, ${item.lng.toStringAsFixed(5)})',
                                            style: AppFonts.style(
                                              fontSize: 14.sp,
                                              color: const Color(0xFF1B8CBE),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Icon(
                                        Icons.location_on,
                                        color: const Color(0xFF1B8CBE),
                                        size: 20.sp,
                                      ),
                                      onTap: () => isFirstInstall
                                          ? controller.handleLocationSelection(item)
                                          : Get.back(result: item),
                                    ),
                                  );
                                },
                              );
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
}
