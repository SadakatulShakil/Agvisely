import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../models/saved_location_model.dart';
import '../../../home/domen/controllers/home_controller.dart';
import '../../../location/data/location_repository.dart';
import '../../../location/domen/binding/select_location_binding.dart';
import '../../../location/presentation/pages/select_location_page.dart';

/// "Favorite Locations" card on the Profile page — reads/writes the exact
class FavoriteLocationsCard extends StatefulWidget {
  const FavoriteLocationsCard({super.key});

  @override
  State<FavoriteLocationsCard> createState() => _FavoriteLocationsCardState();
}

class _FavoriteLocationsCardState extends State<FavoriteLocationsCard> {
  List<SavedLocation> _locations = [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await UserPrefService().getSavedLocations();
    if (!mounted) return;
    setState(() {
      _locations = list;
      _loading = false;
    });
  }

  Future<void> _select(SavedLocation loc) async {
    if (loc.isCurrent || _busy) return;
    setState(() => _busy = true);
    await UserPrefService().setCurrent(loc);
    Get.find<HomeController>().onLocationChanged();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _remove(SavedLocation loc) async {
    if (loc.isCurrent || _busy) return;
    setState(() => _busy = true);
    await UserPrefService().removeLocation(loc.pcode);
    Get.find<HomeController>().refreshLocationName();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _addLocation() async {
    final item = await Get.to<UnionRecord?>(
      () => SelectLocationPage(isFirstInstall: false),
      binding: SelectLocationBinding(),
    );
    if (item == null) return;

    setState(() => _busy = true);
    await Get.find<HomeController>().addCustomLocation(item);
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = Get.locale?.languageCode == 'bn';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: FigmaColors.neutralBackground,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: Text(
                  'profile.favorite_locations'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: FigmaColors.neutralBody,
                  ),
                ),
              ),
              Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 2.h),
                preferBelow: false,
                decoration: BoxDecoration(
                  color: FigmaColors.neutralBody,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                message: 'profile.location_info'.tr,
                child: Icon(
                  Icons.info_outline,
                  size: 20.sp,
                  color: FigmaColors.neutralPlaceholder,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (_loading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: _locations
                  .map(
                    (loc) => _LocationChip(
                      isGps: loc.isGps,
                      label: loc.displayName(isBangla),
                      isCurrent: loc.isCurrent,
                      deletable: !loc.isGps && !loc.isCurrent,
                      onTap: _busy ? null : () => _select(loc),
                      onDelete: _busy ? null : () => _remove(loc),
                    ),
                  )
                  .toList(),
            ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: _busy ? null : _addLocation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 18.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'profile.add_new_location'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.isGps,
    required this.label,
    required this.isCurrent,
    required this.deletable,
    this.onTap,
    this.onDelete,
  });

  final bool isGps;
  final String label;
  final bool isCurrent;
  final bool deletable;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        // Room for the delete badge to overhang the chip without clipping.
        padding: EdgeInsets.only(top: 6.h, right: 6.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isCurrent ? FigmaColors.neutralBorder : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
                border: isCurrent ? Border.all(color: AppColors.primary) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCurrent) ...[
                    Icon(Icons.check_circle, size: 14.sp, color: FigmaColors.primaryDefault),
                    SizedBox(width: 6.w),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                      color: isCurrent ? FigmaColors.primaryDefault : FigmaColors.neutralBody,
                    ),
                  ),
                  if (isGps) ...[
                    SizedBox(width: 6.w),
                    Icon(Icons.gps_fixed, size: 18.sp, color: FigmaColors.chartHumidity),
                  ],
                ],
              ),
            ),
            if (deletable)
              Positioned(
                top: -6.h,
                right: -6.w,
                child: GestureDetector(
                  onTap: onDelete,
                  child: SvgPicture.asset(
                    'assets/icons/svg/cancel_icon.svg',
                    width: 16.w,
                    height: 16.h,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
