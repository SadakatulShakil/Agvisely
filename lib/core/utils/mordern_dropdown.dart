import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme_colors.dart';

/// Shared "premium" popup styling for every `DropdownButtonFormField` in the
/// app — a rounded white card with a soft shadow, instead of Flutter's plain
/// default menu. Pass these to the field's `borderRadius`/`dropdownColor`/
/// `elevation` parameters; wrap each item's label with
/// [premiumDropdownItemLabel].
BorderRadius get premiumDropdownRadius => BorderRadius.circular(16.r);

const Color premiumDropdownColor = FigmaColors.neutralWhite;

const int premiumDropdownElevation = 4;

/// Wraps a [DropdownMenuItem]'s label with generous padding and, when
/// [selected], a soft rounded highlight pill — matches the selected-row
/// treatment in the premium popup style.
Widget premiumDropdownItemLabel(
  String label, {
  required bool selected,
  TextStyle? style,
}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: selected ? FigmaColors.neutralBackground : Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    ),
  );
}
