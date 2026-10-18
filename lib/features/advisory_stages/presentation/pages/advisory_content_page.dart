import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/advisory_pdf_builder.dart';
import '../../../../models/advisory_content_model.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domen/controllers/advisory_content_controller.dart';

/// "See The Advisory" — per the "Crop advisory" Figma frame: a hero photo
/// of the item with the stage name, then a rounded content sheet with the
/// stage's advisory sections, a highlighted "Good Agriculture Practice"
/// card, and Share / Download PDF actions.
class AdvisoryContentPage extends StatelessWidget {
  const AdvisoryContentPage({super.key});

  static const double _heroHeight = 340;
  static const double _sheetOverlap = 24;

  Future<Uint8List> _buildPdf(
    AdvisoryContentController controller,
    AdvisoryContentModel content,
  ) {
    return AdvisoryPdfBuilder.build(
      item: controller.item,
      stage: controller.stage,
      categoryLabel: controller.categoryLabel,
      content: content,
    );
  }

  String _pdfFileName(AdvisoryContentController controller) =>
      '${controller.stage.label(false).replaceAll(' ', '_').toLowerCase()}_advisory.pdf';

  Future<void> _onShare(AdvisoryContentController controller) async {
    final content = controller.content.value;
    if (content == null) return;
    final bytes = await _buildPdf(controller, content);
    await Printing.sharePdf(bytes: bytes, filename: _pdfFileName(controller));
  }

  Future<void> _onDownload(AdvisoryContentController controller) async {
    final content = controller.content.value;
    if (content == null) return;
    final bytes = await _buildPdf(controller, content);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: _pdfFileName(controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvisoryContentController>();
    final isBn = Get.locale?.languageCode == 'bn';

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  _Hero(
                    imageUrl:
                        controller.stage.icon ?? controller.item.imageUrl,
                    title: controller.item.label(isBn),
                    subtitle: controller.stage.label(isBn),
                    height: _heroHeight.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: (_heroHeight - _sheetOverlap).h,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 20.h),
                      decoration: BoxDecoration(
                        color: AppColors.cardLight,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.r),
                          topRight: Radius.circular(24.r),
                        ),
                      ),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final error = controller.errorMessage.value;
                        if (error != null) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.wifi_off_rounded,
                                  size: 36.sp,
                                  color: AppColors.textSecondaryLight,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                TextButton(
                                  onPressed: controller.loadContent,
                                  child: Text('advisory_content.retry'.tr),
                                ),
                              ],
                            ),
                          );
                        }

                        final content = controller.content.value;
                        if (content == null) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _IconBadge(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    controller.categoryLabel ?? '',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            for (
                              var i = 0;
                              i < content.sections.length;
                              i++
                            ) ...[
                              SizedBox(height: 18.h),
                              _Section(
                                section: content.sections[i],
                                isBn: isBn,
                              ),
                              if (i < content.sections.length - 1) ...[
                                SizedBox(height: 14.h),
                                Divider(
                                  color: AppColors.dividerLight,
                                  height: 1,
                                ),
                              ],
                            ],
                            if (content.goodPractice != null) ...[
                              SizedBox(height: 20.h),
                              _GoodPracticeCard(
                                section: content.goodPractice!,
                                isBn: isBn,
                              ),
                            ],
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            final enabled = controller.content.value != null;
            return Container(
              color: AppColors.cardLight,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: enabled ? () => _onShare(controller) : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryDark),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 14.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'advisory_content.share'.tr,
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.ios_share_rounded,
                          color: AppColors.primaryDark,
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: enabled ? () => _onDownload(controller) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        disabledBackgroundColor: AppColors.primaryDark
                            .withValues(alpha: 0.4),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'advisory_content.download_pdf'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.file_download_outlined,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Hero photo with a back button and a bottom gradient scrim carrying the
/// item name + stage name.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.height,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null && url.isNotEmpty)
            Image.network(
              '${ApiEndpoints.baseUrlUserHost}$url',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      Container(color: AppColors.accent),
            )
          else
            Container(color: AppColors.accent),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            top: 12.h,
            left: 12.w,
            child: SafeArea(
              bottom: false,
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12.h,
            right: 12.w,
            child: SafeArea(
              bottom: false,
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                child: IconButton(
                  icon: Icon(Icons.home_rounded, color: AppColors.primaryDark),
                  onPressed: () => Get.offAll(() => const HomePage()),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 36.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.9),
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

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(Icons.eco, size: 16.sp, color: AppColors.primary),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.section, required this.isBn});

  final AdvisorySectionModel section;
  final bool isBn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.label(isBn),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        SizedBox(height: 8.h),
        for (final bullet in section.bullets) _Bullet(text: bullet.label(isBn)),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Container(
              width: 4.w,
              height: 4.w,
              decoration: const BoxDecoration(
                color: AppColors.textSecondaryLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textPrimaryLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoodPracticeCard extends StatelessWidget {
  const _GoodPracticeCard({required this.section, required this.isBn});

  final AdvisorySectionModel section;
  final bool isBn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryDark.withValues(alpha: 0.30),
            AppColors.primaryDark.withValues(alpha: 0.08),
            AppColors.primaryDark.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.50, 1.0],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(color: AppColors.cardLight),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  section.label(isBn),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          for (final bullet in section.bullets)
            _Bullet(text: bullet.label(isBn)),
        ],
      ),
    );
  }
}
