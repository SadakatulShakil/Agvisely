import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/advisory_pdf_builder.dart';
import '../../../../models/advisory_content_model.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domen/controllers/advisory_content_controller.dart';

class AdvisoryContentPage extends StatelessWidget {
  const AdvisoryContentPage({super.key});

  static const double _heroHeight = 340;
  static const double _sheetOverlap = 24;

  Future<Uint8List> _buildPdf(
    AdvisoryContentController controller,
    AdvisoryContentModel content,
    bool isBn,
  ) {
    return AdvisoryPdfBuilder.build(
      item: controller.item,
      stage: controller.stage,
      categoryLabel: controller.categoryLabel,
      content: content,
      isBn: isBn,
    );
  }

  String _pdfFileName(AdvisoryContentController controller) =>
      '${controller.stage.label(false).replaceAll(' ', '_').toLowerCase()}_advisory.pdf';

  Future<void> _onShare(AdvisoryContentController controller, bool isBn) async {
    final content = controller.content.value;
    if (content == null) return;
    final bytes = await _buildPdf(controller, content, isBn);
    await Printing.sharePdf(bytes: bytes, filename: _pdfFileName(controller));
  }

  Future<void> _onDownload(AdvisoryContentController controller, bool isBn) async {
    final content = controller.content.value;
    if (content == null) return;
    final bytes = await _buildPdf(controller, content, isBn);
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
            child: RefreshIndicator(
              onRefresh: controller.loadContent,
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
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
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: FigmaColors.primaryDefault,
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
                                useHtml: controller.isDisease,
                              ),
                              if (i < content.sections.length - 1) ...[
                                SizedBox(height: 20.h),
                                Divider(
                                  color: FigmaColors.neutralBackground,
                                  height: 1,
                                ),
                              ],
                            ],
                            if (content.goodPractice != null) ...[
                              controller.isDisease
                                  ?SizedBox(height: 8.h)
                                  :SizedBox(height: 36.h),
                              _GoodPracticeCard(
                                section: content.goodPractice!,
                                isBn: isBn,
                                useHtml: controller.isDisease,
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
          ),
          Obx(() {
            final enabled = controller.content.value != null;
            return Container(
              color: FigmaColors.neutralWhite,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: enabled ? () => _onShare(controller, isBn) : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: FigmaColors.primaryDefault),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'advisory_content.share'.tr,
                          style: TextStyle(
                            color: FigmaColors.primaryDefault,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        SvgPicture.asset(
                          'assets/icons/svg/share_btn.svg',
                          width: 18.w,
                          height: 18.h,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: enabled ? () => _onDownload(controller, isBn) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FigmaColors.primaryDefault,
                        disabledBackgroundColor: FigmaColors.primaryDefault
                            .withValues(alpha: 0.4),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          side: BorderSide(color: FigmaColors.primaryLight)
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'advisory_content.download_pdf'.tr,
                            style: TextStyle(
                              color: FigmaColors.neutralWhite,
                              fontWeight: FontWeight.w500,
                              fontSize: 17.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SvgPicture.asset(
                            'assets/icons/svg/download_btn.svg',
                            width: 18.w,
                            height: 18.h,
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
            top: 20.h,
            left: 20.w,
            child: SafeArea(
              bottom: false,
              child: CircleAvatar(
                backgroundColor: FigmaColors.primaryTint,
                child: IconButton(
                  icon: SvgPicture.asset('assets/icons/svg/arrow_back.svg', width: 24.w, height: 24.h),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20.h,
            right: 20.w,
            child: SafeArea(
              bottom: false,
              child: CircleAvatar(
                backgroundColor: FigmaColors.primaryTint,
                child: IconButton(
                  icon: SvgPicture.asset('assets/icons/svg/back_home_btn.svg', width: 24.w, height: 24.h),
                  onPressed: () => Get.offAll(() => const HomePage()),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 16.w,
            bottom: 36.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: FigmaColors.neutralWhite,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: FigmaColors.neutralWhite,
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
  const _Section({required this.section, required this.isBn, required this.useHtml});

  final AdvisorySectionModel section;
  final bool isBn;
  final bool useHtml;

  @override
  Widget build(BuildContext context) {
    final title = section.label(isBn);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: FigmaColors.primaryDark,
            ),
          ),
          SizedBox(height: 12.h),
        ],
        if (useHtml)
          _AdvisoryHtmlBody(html: section.content(isBn))
        else
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
      padding: EdgeInsets.only(bottom: 8.h, left: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: FigmaColors.primaryDefault,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: FigmaColors.neutralBody,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/// used only for the Disease flow, see [_Section.useHtml].
class _AdvisoryHtmlBody extends StatelessWidget {
  const _AdvisoryHtmlBody({required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    if (html.trim().isEmpty) return const SizedBox.shrink();
    return Html(
      data: html,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(16.sp),
          color: FigmaColors.neutralBody,
          lineHeight: LineHeight.number(1.4),
        ),
        'p': Style(margin: Margins.only(bottom: 8.h)),
        'ul': Style(margin: Margins.zero, padding: HtmlPaddings.only(left: 20.w)),
        'li': Style(margin: Margins.only(bottom: 8.h)),
      },
    );
  }
}

class _GoodPracticeCard extends StatelessWidget {
  const _GoodPracticeCard({required this.section, required this.isBn, required this.useHtml});

  final AdvisorySectionModel section;
  final bool isBn;
  final bool useHtml;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: useHtml
          ?EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h)
          :EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 16.h),
      decoration: useHtml
          ? null
          : BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            FigmaColors.primaryDefault.withValues(alpha: 0.15),
            FigmaColors.primaryDefault.withValues(alpha: 0.06),
            FigmaColors.primaryDefault.withValues(alpha: 0.0),
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
          useHtml
              ?SizedBox.shrink()
              :Row(
            children: [
              _IconBadge(color: AppColors.cardLight),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  section.label(isBn),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: FigmaColors.primaryDefault,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (useHtml)
            _AdvisoryHtmlBody(html: section.content(isBn))
          else
            for (final bullet in section.bullets) _Bullet(text: bullet.label(isBn)),
        ],
      ),
    );
  }
}
