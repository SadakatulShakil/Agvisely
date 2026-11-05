import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/advisory_pdf_builder.dart';
import '../../../../core/utils/empty_state_widget.dart';
import '../../../../core/utils/pinch_pdf_view.dart';
import '../../../../models/advisory_content_model.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domen/controllers/advisory_content_controller.dart';

class AdvisoryContentPage extends StatelessWidget {
  const AdvisoryContentPage({super.key});

  static const double _heroHeight = 340;
  static const double _sheetOverlap = 30;
  // Room for the icon row + two-line centered title/subtitle, comfortably —
  // taller than a bare kToolbarHeight so both lines are never cramped.
  static const double _collapsedBodyHeight = 120;

  Future<Uint8List> _resolvePdfBytes(
    AdvisoryContentController controller,
    AdvisoryContentModel content,
    bool isBn,
  ) async {
    final pdfUrl = content.pdfUrl;
    if (pdfUrl != null) {
      final resolvedUrl =
          pdfUrl.startsWith('http')
              ? pdfUrl
              : '${ApiEndpoints.baseUrlUserHost}$pdfUrl';
      final resp = await http.get(Uri.parse(resolvedUrl));
      if (resp.statusCode == 200) return resp.bodyBytes;
    }

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
    final bytes = await _resolvePdfBytes(controller, content, isBn);
    await Printing.sharePdf(bytes: bytes, filename: _pdfFileName(controller));
  }

  Future<void> _onDownload(
    AdvisoryContentController controller,
    bool isBn,
  ) async {
    final content = controller.content.value;
    if (content == null) return;
    final bytes = await _resolvePdfBytes(controller, content, isBn);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: _pdfFileName(controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvisoryContentController>();
    final isBn = Get.locale?.languageCode == 'bn';
    final topPadding = MediaQuery.of(context).padding.top;
    final collapsedExtent = topPadding + _collapsedBodyHeight.h;

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final content = controller.content.value;
              final isPdf = content != null && content.pdfUrl != null;

              // The app bar overlay is a separate, later Stack child so it
              // is *always* painted above the scrolling body beneath it —
              // guaranteed by plain Stack paint order, rather than relying
              // on sliver-pinning internals (which let scrolled content
              // paint over the icons/title).
              return Stack(
                children: [
                  if (isPdf)
                    _PdfScrollBody(
                      controller: controller,
                      content: content,
                      isBn: isBn,
                      collapsedExtent: collapsedExtent,
                    )
                  else
                    RefreshIndicator(
                      onRefresh: controller.loadContent,
                      child: CustomScrollView(
                        controller: controller.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _HeroBackdropDelegate(
                              imageUrl:
                                  controller.stage.icon ??
                                  controller.item.imageUrl,
                              title: controller.item.label(isBn),
                              subtitle: controller.stage.label(isBn),
                              expandedHeight: _heroHeight.h,
                              collapsedHeight: collapsedExtent,
                              sheetOverlap: _sheetOverlap.h,
                            ),
                          ),
                          SliverToBoxAdapter(
                            // Flush below the header — the rounded overlap
                            // "peek" is painted inside the header itself
                            // (same AppColors.cardLight), so this box is a
                            // plain flat-topped continuation of it.
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                10.h,
                                20.w,
                                20.h,
                              ),
                              color: AppColors.cardLight,
                              child: Obx(() {
                                if (controller.isLoading.value) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 40.h,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final error = controller.errorMessage.value;
                                if (error != null) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 100.h),
                                    child: EmptyStateWidget(
                                      message: 'advisory_stages.empty_for'
                                          .trParams({
                                            'item': controller.item.label(isBn),
                                          }),
                                    ),
                                  );
                                }

                                final content = controller.content.value;
                                if (content == null) {
                                  return const SizedBox.shrink();
                                }

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
                                          ? SizedBox(height: 8.h)
                                          : SizedBox(height: 36.h),
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
                  _CollapsingAppBarOverlay(
                    scrollController: controller.scrollController,
                    expandedExtent: _heroHeight.h,
                    collapsedExtent: collapsedExtent,
                    topPadding: topPadding - 20.h,
                    title: controller.item.label(isBn),
                    subtitle: controller.stage.label(isBn),
                  ),
                ],
              );
            }),
          ),
          Obx(() {
            final enabled = controller.content.value != null;
            return Container(
              color: FigmaColors.neutralWhite,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed:
                        enabled ? () => _onShare(controller, isBn) : null,
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
                      onPressed:
                          enabled ? () => _onDownload(controller, isBn) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FigmaColors.primaryDefault,
                        disabledBackgroundColor: FigmaColors.primaryDefault
                            .withValues(alpha: 0.4),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          side: BorderSide(color: FigmaColors.primaryLight),
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.asset, required this.onPressed});

  final String asset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: FigmaColors.primaryTint,
      child: IconButton(
        icon: SvgPicture.asset(asset, width: 24.w, height: 24.h),
        onPressed: onPressed,
      ),
    );
  }
}

class _HeroBackdropDelegate extends SliverPersistentHeaderDelegate {
  _HeroBackdropDelegate({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.sheetOverlap,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;
  final double expandedHeight;
  final double collapsedHeight;
  final double sheetOverlap;

  @override
  double get minExtent => collapsedHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final effectiveShrinkOffset =
        range <= 0 ? 0.0 : shrinkOffset.clamp(0.0, range);
    final t =
        range <= 0 ? 1.0 : (effectiveShrinkOffset / range).clamp(0.0, 1.0);
    // Fades out over the first 70% of the collapse so the photo/caption/peek
    final expandedOpacity = (1 - t / 0.7).clamp(0.0, 1.0);

    final url = imageUrl;

    return SizedBox(
      height: maxExtent - effectiveShrinkOffset,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: FigmaColors.primaryDefault),
          Opacity(
            opacity: expandedOpacity,
            child:
                url != null && url.isNotEmpty
                    ? Image.network(
                      '${ApiEndpoints.baseUrlUserHost}$url',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Container(color: AppColors.accent),
                    )
                    : Container(color: AppColors.accent),
          ),
          Opacity(
            opacity: expandedOpacity,
            child: DecoratedBox(
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
          ),
          // Rounded "peek" strip — the bottom sheetOverlap of the header,
          // painted in the content card's color so the sheet below can
          // start flush with zero rounding and still look like one
          // continuous rounded-top card overlapping the hero's bottom edge.
          // Always visible (not tied to expandedOpacity) — it's a permanent
          // part of the header/sheet boundary, not just a hero-photo detail,
          // so it still shows once fully collapsed.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: sheetOverlap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
            ),
          ),
          // Large bottom-left caption — expanded state only.
          Positioned(
            left: 20.w,
            right: 16.w,
            bottom: 36.h,
            child: Opacity(
              opacity: expandedOpacity,
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
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HeroBackdropDelegate oldDelegate) {
    return imageUrl != oldDelegate.imageUrl ||
        title != oldDelegate.title ||
        subtitle != oldDelegate.subtitle ||
        expandedHeight != oldDelegate.expandedHeight ||
        collapsedHeight != oldDelegate.collapsedHeight ||
        sheetOverlap != oldDelegate.sheetOverlap;
  }
}

/// Always-on-top app bar: back (left) / home (right) icons plus a small
class _CollapsingAppBarOverlay extends StatefulWidget {
  const _CollapsingAppBarOverlay({
    required this.scrollController,
    required this.expandedExtent,
    required this.collapsedExtent,
    required this.topPadding,
    required this.title,
    required this.subtitle,
  });

  final ScrollController scrollController;
  final double expandedExtent;
  final double collapsedExtent;
  final double topPadding;
  final String title;
  final String subtitle;

  @override
  State<_CollapsingAppBarOverlay> createState() =>
      _CollapsingAppBarOverlayState();
}

class _CollapsingAppBarOverlayState extends State<_CollapsingAppBarOverlay> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _CollapsingAppBarOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final range = widget.expandedExtent - widget.collapsedExtent;
    final offset =
        widget.scrollController.hasClients
            ? widget.scrollController.offset
            : 0.0;
    final t = range <= 0 ? 1.0 : (offset / range).clamp(0.0, 1.0);
    // Starts fading in once the collapse is 30% done, fully in by 100% —
    // matches the backdrop's caption/photo fade-out timing (gone by 70%).
    final collapsedTitleOpacity = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    final bodyHeight = widget.collapsedExtent - widget.topPadding;

    return Positioned(
      top: widget.topPadding,
      left: 0,
      right: 0,
      height: bodyHeight,
      child: Stack(
        children: [
          Positioned(
            left: 64.w,
            right: 64.w,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: collapsedTitleOpacity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: FigmaColors.neutralWhite,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: FigmaColors.neutralWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: _CircleIconButton(
                asset: 'assets/icons/svg/arrow_back.svg',
                onPressed: () => Get.back(),
              ),
            ),
          ),
          Positioned(
            right: 20.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: _CircleIconButton(
                asset: 'assets/icons/svg/back_home_btn.svg',
                onPressed: () => Get.offAll(() => const HomePage()),
              ),
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

/// PDF-stage scroll body — same collapsing hero backdrop as the sections
class _PdfScrollBody extends StatelessWidget {
  const _PdfScrollBody({
    required this.controller,
    required this.content,
    required this.isBn,
    required this.collapsedExtent,
  });

  final AdvisoryContentController controller;
  final AdvisoryContentModel content;
  final bool isBn;
  final double collapsedExtent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pdfHeight = (constraints.maxHeight - collapsedExtent).clamp(
          300.h,
          double.infinity,
        );

        return CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _HeroBackdropDelegate(
                imageUrl: controller.stage.icon ?? controller.item.imageUrl,
                title: controller.item.label(isBn),
                subtitle: controller.stage.label(isBn),
                expandedHeight: AdvisoryContentPage._heroHeight.h,
                collapsedHeight: collapsedExtent,
                sheetOverlap: AdvisoryContentPage._sheetOverlap.h,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                height: pdfHeight,
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                color: AppColors.cardLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _IconBadge(
                          color: AppColors.primary.withValues(alpha: 0.12),
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
                    SizedBox(height: 18.h),
                    Expanded(child: _InlinePdfView(url: content.pdfUrl!)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.section,
    required this.isBn,
    required this.useHtml,
  });

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
          for (final bullet in section.bullets)
            _Bullet(text: bullet.label(isBn)),
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

class _InlinePdfView extends StatelessWidget {
  const _InlinePdfView({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl =
        url.startsWith('http') ? url : '${ApiEndpoints.baseUrlUserHost}$url';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: PinchPdfView(url: resolvedUrl),
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
        'ul': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.only(left: 20.w),
        ),
        'li': Style(margin: Margins.only(bottom: 8.h)),
      },
    );
  }
}

class _GoodPracticeCard extends StatelessWidget {
  const _GoodPracticeCard({
    required this.section,
    required this.isBn,
    required this.useHtml,
  });

  final AdvisorySectionModel section;
  final bool isBn;
  final bool useHtml;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          useHtml
              ? EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h)
              : EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 16.h),
      decoration:
          useHtml
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
              ? SizedBox.shrink()
              : Row(
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
            for (final bullet in section.bullets)
              _Bullet(text: bullet.label(isBn)),
        ],
      ),
    );
  }
}
