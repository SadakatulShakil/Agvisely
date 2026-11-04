import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/services/user_feedback_service.dart';
import '../../../../core/theme/app_theme_colors.dart';

/// The popup a `'dialog'`-type custom-code node opens — a free-text
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  static Future<void> show() => Get.dialog(const FeedbackDialog());

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _controller = TextEditingController();
  bool _submitting = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final result = await UserFeedbackService().submit(_controller.text);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      Get.back();
      Get.snackbar('', 'menu.feedback_success'.tr);
    } else {
      Get.snackbar('menu.feedback_failed'.tr, result.error ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        'menu.feedback_title'.tr,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 5,
        maxLength: 1000,
        decoration: InputDecoration(
          hintText: 'menu.feedback_hint'.tr,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Get.back(),
          child: Text('common.cancel'.tr),
        ),
        ElevatedButton(
          onPressed: (_submitting || !_hasText) ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child:
              _submitting
                  ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text('menu.feedback_send'.tr),
        ),
      ],
    );
  }
}
