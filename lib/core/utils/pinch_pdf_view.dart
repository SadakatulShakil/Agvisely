import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';

class PinchPdfView extends StatefulWidget {
  const PinchPdfView({super.key, required this.fetchBytes});

  /// Fetches the PDF's raw bytes — called once, in [initState].
  final Future<Uint8List> Function() fetchBytes;

  @override
  State<PinchPdfView> createState() => _PinchPdfViewState();
}

class _PinchPdfViewState extends State<PinchPdfView> {
  late final PdfControllerPinch _controller;

  /// Below this zoom ratio, [_snapBackIfNeeded] pulls the view back to an
  /// exact fit on release — pdfx's own InteractiveViewer just hard-clamps at
  /// minScale instead of animating back, so pinching out normally leaves it
  /// a few percent off a clean 1:1 fit.
  static const double _snapBackThreshold = 1.15;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openData(widget.fetchBytes()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
              (_) => const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder:
              (_) => const Center(child: CircularProgressIndicator()),
          errorBuilder:
              (_, __) => Center(child: Text('menu.pdf_load_failed'.tr)),
        ),
      ),
    );
  }
}
