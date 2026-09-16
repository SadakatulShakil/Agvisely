import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../models/saved_location_model.dart';
import '../../../location/data/location_repository.dart';
import '../../../location/domen/binding/select_location_binding.dart';
import '../../../location/presentation/pages/select_location_page.dart';
import '../../domen/controllers/home_controller.dart';

/// Bottom sheet listing the GPS "Current Location" entry + custom saved
/// locations, with instant switching, edit/delete on custom entries, and an
/// "Add location" tile that opens the flat SelectLocationPage.
class SavedLocationsSheet extends StatefulWidget {
  const SavedLocationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SavedLocationsSheet(),
    );
  }

  @override
  State<SavedLocationsSheet> createState() => _SavedLocationsSheetState();
}

class _SavedLocationsSheetState extends State<SavedLocationsSheet> {
  static const _blue = Color(0xFF1B8CBE);

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

  Future<void> _selectLocation(SavedLocation loc) async {
    if (loc.isCurrent) return;
    setState(() => _busy = true);
    await UserPrefService().setCurrent(loc);
    Get.find<HomeController>().onLocationChanged();
    // Navigator.pop (not Get.back) — this closes the specific route this
    // sheet was pushed as, reliably, regardless of GetX's own routing state.
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _removeLocation(SavedLocation loc) async {
    if (loc.isCurrent) return; // never remove the active location
    setState(() => _busy = true);
    await UserPrefService().removeLocation(loc.pcode);
    Get.find<HomeController>().refreshLocationName();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _editLocation(SavedLocation loc, bool isBangla) async {
    final controller = TextEditingController(
      text: isBangla ? loc.nameBn : loc.name,
    );
    final newName = await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          isBangla ? 'নাম পরিবর্তন করুন' : 'Rename location',
          style: AppFonts.style(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isBangla ? 'নতুন নাম লিখুন' : 'Enter new name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isBangla ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: controller.text),
            child: Text(isBangla ? 'সংরক্ষণ' : 'Save'),
          ),
        ],
      ),
    );
    if (newName == null || newName.trim().isEmpty) return;

    setState(() => _busy = true);
    await UserPrefService().renameCustomLocation(
      loc.pcode,
      isBangla: isBangla,
      newName: newName.trim(),
    );
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

    // Close immediately — resolving the pick via the API can take a moment,
    // and the user shouldn't have to wait in this sheet for it. HomeController
    // resolves + saves it in the background and drives a small loader on the
    // weather card until it's done.
    if (mounted) Navigator.of(context).pop();
    Get.find<HomeController>().addCustomLocation(item);
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = Get.locale?.languageCode == 'bn';
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.75.sh),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isBangla ? 'লোকেশন সমূহ' : 'Locations',
                    style: AppFonts.style(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: 25.sp, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _locations.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, i) => _row(_locations[i], isBangla),
                ),
              ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: _busy ? null : _addLocation,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_location_alt, color: _blue, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      isBangla ? 'লোকেশন যোগ করুন' : 'Add location',
                      style: AppFonts.style(
                        color: _blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(SavedLocation loc, bool isBangla) {
    // Custom entries already carry "Union, Upazila" as their name (set at
    // pick time in SelectLocationController/HomeController), so the
    // district alone is enough for their subtitle without repeating upazila.
    // The GPS row's title is the fixed "Current Location" label instead, so
    // its subtitle keeps showing upazila+district for full context.
    final title =
        loc.isGps
            ? (isBangla ? 'বর্তমান অবস্থান' : 'Current Location')
            : (isBangla ? loc.nameBn : loc.name);
    final subtitle =
        loc.isGps
            ? (isBangla
                ? '${loc.upazilaBn}, ${loc.districtBn}'
                : '${loc.upazila}, ${loc.district}')
            : (isBangla ? loc.districtBn : loc.district);

    return Container(
      decoration: BoxDecoration(
        color:
            loc.isCurrent
                ? Colors.green.withValues(alpha: 0.06)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: loc.isCurrent ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        onTap: _busy ? null : () => _selectLocation(loc),
        leading: Icon(
          loc.isGps ? Icons.gps_fixed : Icons.location_on,
          color: loc.isGps ? Colors.grey.shade600 : Colors.green.shade600,
          size: 22.sp,
        ),
        title: Text(
          title,
          style: AppFonts.style(fontWeight: FontWeight.w600, fontSize: 15.sp),
        ),
        subtitle: Text(
          subtitle,
          style: AppFonts.style(fontSize: 13.sp, color: Colors.black54),
        ),
        // Fixed-width slots (check + menu) so the menu column lines up across
        // every row regardless of whether the check icon is showing.
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24.w,
              child:
                  loc.isCurrent
                      ? Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 20.sp,
                        ),
                      )
                      : null,
            ),
            loc.isGps
                ? SizedBox.shrink()
                : SizedBox(
                  width: 32.w,
                  child: Center(
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert,
                        size: 20.sp,
                        color: Colors.black45,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') _editLocation(loc, isBangla);
                        if (value == 'delete') _removeLocation(loc);
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(isBangla ? 'সম্পাদনা করুন' : 'Edit'),
                            ),
                            // Never offer to delete the active location.
                            if (!loc.isCurrent)
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(isBangla ? 'ডিলিট করুন' : 'Delete'),
                              ),
                          ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
