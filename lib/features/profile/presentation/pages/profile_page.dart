import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/user_avatar.dart';
import '../../../auth/auth/presentation/pages/login_page.dart';
import '../../../auth/auth/presentation/widgets/auth_widgets.dart';
import '../../../settings/domen/controllers/settings_controller.dart';
import '../../../home/domen/controllers/home_controller.dart';
import '../../domen/controllers/profile_controller.dart';
import '../widgets/favorite_locations_card.dart';

/// Profile screen — matches the Figma "Profile" frame. Name comes from the
/// cached/live user profile ([ProfileController]); avatar/role are still
/// static. Favorite Locations is real (same saved-locations list as the
/// home page); Language is wired to [SettingsController]; Edit profile /
/// My Choice have no destination page yet, so their taps are no-ops.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final c = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);

    return SageBackground(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            Obx(
              () => Center(
                child: UserAvatar(
                  profileUrl: c.user.value?.profileUrl,
                  size: 96.w,
                  iconSize: 56.sp,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Obx(
              () => Center(
                child: Text(
                  c.user.value?.name ?? '',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Obx(
              () => Center(
                child: Text(
                  c.profession.value?.label(Get.locale?.languageCode == 'bn') ?? '',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            const FavoriteLocationsCard(),
            SizedBox(height: 8.h),
            _MenuRow(label: 'profile.edit_profile'.tr, onTap: () {}),
            Divider(color: AppColors.dividerLight),
            _MenuRow(label: 'home.my_choice'.tr, onTap: () {}),
            Divider(color: AppColors.dividerLight),
            InkWell(
              // Whole row toggles the language — not just the small pill —
              // so the tap target isn't limited to the pill's tight bounds.
              onTap: () => settings.setLanguage(settings.language.value == 'bn' ? 'en' : 'bn'),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'common.language'.tr,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.navy,
                      ),
                    ),
                    Obx(
                      () => _LanguageToggle(isBangla: settings.language.value == 'bn'),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: AppColors.dividerLight),
            _MenuRow(
              label: 'profile.logout'.tr,
              color: AppColors.danger,
              icon: Icons.logout,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final isBangla = Get.locale?.languageCode == 'bn';
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(isBangla ? 'লগ আউট' : 'Logout'),
        content: Text(
          isBangla ? 'আপনি কি লগ আউট করতে চান?' : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(isBangla ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              isBangla ? 'লগ আউট' : 'Logout',
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await UserPrefService().clearSession();
    // HomeController/ProfileController are permanent singletons — their
    // state survives this logout, so without resetting them a login right
    // after logging out from the Profile tab would land back on Profile
    // instead of Home, and would briefly flash the previous user's name.
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().navIndex.value = 0;
    }
    if (Get.isRegistered<ProfileController>()) {
      final profileC = Get.find<ProfileController>();
      profileC.user.value = null;
      profileC.profession.value = null;
    }
    Get.offAll(() => const LoginPage());
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, this.onTap, this.color, this.icon});

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.navy,
              ),
            ),
            Icon(icon ?? Icons.chevron_right, size: 20.sp, color: color ?? AppColors.navy),
          ],
        ),
      ),
    );
  }
}

/// Pure display — the enclosing row's [InkWell] handles the tap, so this
/// only reflects which side ([isBangla]) is currently active.
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.isBangla});

  final bool isBangla;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment('EN', active: !isBangla),
          _segment('BN', active: isBangla),
        ],
      ),
    );
  }

  Widget _segment(String label, {required bool active}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: active ? AppColors.primaryDark : Colors.white,
        ),
      ),
    );
  }
}
