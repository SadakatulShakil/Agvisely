import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_theme_colors.dart';

/// Sage top-to-bottom gradient used across splash / onboarding / auth.
class SageBackground extends StatelessWidget {
  final Widget child;
  const SageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF678042).withValues(alpha: 0.0),
                  const Color(0xFF678042).withValues(alpha: 0.18),
                  const Color(0xFF678042).withValues(alpha: 0.19),
                  const Color(0xFF678042).withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.25, 0.73, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Full-width primary action button matching the Figma "Request OTP" pill.
class AgButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool showArrow;

  const AgButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62.h,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  if (showArrow) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.arrow_forward, size: 20.sp),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Olive label above an input, as in the design.
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(text,
            style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500)),
      );
}

InputDecoration agFieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F6F1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    );
