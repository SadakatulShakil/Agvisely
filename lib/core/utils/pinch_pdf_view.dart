import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

import '../theme/app_theme_colors.dart';

class PinchPdfView extends StatefulWidget {
  const PinchPdfView({super.key, required this.url});

  /// Downloaded once, in [initState], tracking progress as it streams in.
  final String url;

  @override
  State<PinchPdfView> createState() => _PinchPdfViewState();
}

class _PinchPdfViewState extends State<PinchPdfView> {
  late final PdfControllerPinch _controller;

  /// 0.0-1.0 download progress, null while the response's total size is
  /// unknown (no Content-Length header) — the loader then just spins.
  final ValueNotifier<double?> _downloadProgress = ValueNotifier(null);

  /// Below this zoom ratio, [_snapBackIfNeeded] pulls the view back to an
  /// exact fit on release — pdfx's own InteractiveViewer just hard-clamps at
  /// minScale instead of animating back, so pinching out normally leaves it
  /// a few percent off a clean 1:1 fit.
  static const double _snapBackThreshold = 1.15;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(document: PdfDocument.openData(_fetchBytes()));
  }

  Future<Uint8List> _fetchBytes() async {
    final client = http.Client();
    try {
      final response = await client.send(
        http.Request('GET', Uri.parse(widget.url)),
      );
      if (response.statusCode != 200) {
        throw Exception('menu.pdf_load_failed'.tr);
      }

      final total = response.contentLength;
      final bytes = <int>[];
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        if (total != null && total > 0) {
          _downloadProgress.value = bytes.length / total;
        }
      }
      return Uint8List.fromList(bytes);
    } finally {
      client.close();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _downloadProgress.dispose();
    super.dispose();
  }

  void _snapBackIfNeeded(ScaleEndDetails _) {
    if (_controller.zoomRatio > _snapBackThreshold) return;
    final fit = _controller.calculatePageFitMatrix(
      pageNumber: _controller.page,
    );
    if (fit != null) {
      _controller.goTo(
        destination: fit,
        duration: const Duration(milliseconds: 220),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // PdfViewPinch wraps its document in its own SafeArea internally. When
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: PdfViewPinch(
        controller: _controller,
        onInteractionEnd: _snapBackIfNeeded,
        // Default includes a BoxShadow around every page — flat white reads
        // cleaner against our own card background and matches the no-shadow
        // look everywhere else in the app.
        backgroundDecoration: const BoxDecoration(color: Colors.white),
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder:
              (_) => _PdfLoadingIndicator(progress: _downloadProgress),
          pageLoaderBuilder:
              (_) => const Center(child: CircularProgressIndicator()),
          errorBuilder:
              (_, __) => Center(child: Text('menu.pdf_load_failed'.tr)),
        ),
      ),
    );
  }
}

/// Spinner with the download percentage (once known) just below it.
class _PdfLoadingIndicator extends StatelessWidget {
  const _PdfLoadingIndicator({required this.progress});

  final ValueListenable<double?> progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<double?>(
        valueListenable: progress,
        builder: (context, value, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(value: value),
              SizedBox(height: 12.h),
              Text(
                value == null
                    ? 'menu.pdf_loading'.tr
                    : 'menu.pdf_loading_percent'.trParams({
                      'percent': '${(value * 100).round()}',
                    }),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: FigmaColors.neutralSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
