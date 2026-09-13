import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_fonts.dart';

class ForceUpdateDialog extends StatefulWidget {
  final VoidCallback onUpdatePressed;
  final String? storeVersion; // optional: show "Version X.X.X available"

  const ForceUpdateDialog({
    super.key,
    required this.onUpdatePressed,
    this.storeVersion,
  });

  /// Convenience static method — shows the sheet and blocks until user acts.
  static Future<void> show(
      BuildContext context, {
        required VoidCallback onUpdatePressed,
        String? storeVersion,
      }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,   // tap outside → nothing
      enableDrag: false,      // swipe down → nothing
      isScrollControlled: true,
      useRootNavigator: true, // renders above any nested navigators
      backgroundColor: Colors.transparent,
      builder: (_) => ForceUpdateDialog(
        onUpdatePressed: onUpdatePressed,
        storeVersion: storeVersion,
      ),
    );
  }

  @override
  State<ForceUpdateDialog> createState() => _ForceUpdateDialogState();
}

class _ForceUpdateDialogState extends State<ForceUpdateDialog> {
  bool _isLoading = false;

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    widget.onUpdatePressed();
    // Don't set isLoading back to false — the App Store will take focus.
    // If the user comes back without updating, the splash re-checks.
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(
          24.w,
          12.h,
          24.w,
          MediaQuery.of(context).padding.bottom + 24.h, // safe area aware
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle (visual only — drag is disabled) ──────────────
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
            SizedBox(height: 24.h),

            // ── Store logo row ────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.apple, size: 22.sp, color: const Color(0xFF444444)),
                SizedBox(width: 6.w),
                Text(
                  'App Store',
                  style: AppFonts.style(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF444444),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // ── Headline ──────────────────────────────────────────────────
            Text(
              'Update available',
              style: AppFonts.style(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF202124),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.storeVersion != null
                  ? 'Version ${widget.storeVersion} is available. Update to continue.'
                  : 'To use this app, download the latest version.',
              style: AppFonts.style(fontSize: 14.sp, color: const Color(0xFF5F6368)),
            ),
            SizedBox(height: 20.h),

            // ── App info row ──────────────────────────────────────────────
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    'assets/images/agvisely-logo.png',
                    width: 52.w,
                    height: 52.h,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.teal.shade100),
                      ),
                      child: Icon(Icons.wb_cloudy_outlined,
                          color: Colors.teal, size: 28.sp),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agvisely',
                      style: AppFonts.style(
                          fontSize: 15.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '4+  •  Agriculture',
                      style:
                      AppFonts.style(fontSize: 12.sp, color: const Color(0xFF5F6368)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.h),

            const Divider(height: 1),
            SizedBox(height: 16.h),

            // ── Collapsible "What's new" ───────────────────────────────────
            const _WhatsNewSection(),
            SizedBox(height: 24.h),

            // ── Action buttons ─────────────────────────────────────────────
            Row(
              children: [
                // "More info" — secondary, also goes to store
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleUpdate,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF007AFF)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'More info',
                      style: AppFonts.style(color: const Color(0xFF007AFF)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // "Update" — primary CTA
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      disabledBackgroundColor:
                      const Color(0xFF007AFF).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 18.h,
                      width: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Update',
                      style: AppFonts.style(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collapsible "What's new" section
// ─────────────────────────────────────────────────────────────────────────────

class _WhatsNewSection extends StatefulWidget {
  const _WhatsNewSection();

  @override
  State<_WhatsNewSection> createState() => _WhatsNewSectionState();
}

class _WhatsNewSectionState extends State<_WhatsNewSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's new",
                    style: AppFonts.style(
                        fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Bug fixes & performance improvements',
                    style: AppFonts.style(
                        fontSize: 12.sp, color: const Color(0xFF5F6368)),
                  ),
                ],
              ),
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: const Color(0xFF5F6368),
              ),
            ],
          ),
          if (_expanded) ...[
            SizedBox(height: 12.h),
            // Update these notes before each release.
            Text(
              '• Improved advisory accuracy\n'
                  '• Faster app launch on first install\n'
                  '• Fixed crash when location permission is denied\n'
                  '• UI improvements across all screens',
              style: AppFonts.style(
                fontSize: 13.sp,
                color: const Color(0xFF444444),
                height: 1.7,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
