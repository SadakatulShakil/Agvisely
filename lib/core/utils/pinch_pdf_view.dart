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

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(document: PdfDocument.openData(widget.fetchBytes()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PdfViewPinch wraps its document in its own SafeArea internally. When
    // this is embedded well below the real status bar (e.g. inside another
    // page's own layout, with no ancestor SafeArea to already zero out the
    // device insets), that inner SafeArea re-applies the device's real
    // top/bottom insets deep inside the viewer, pushing the actual PDF
    // content down and leaving a blank gap above it. Stripping the ambient
    // MediaQuery padding here makes that inner SafeArea a no-op.
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: PdfViewPinch(
        controller: _controller,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, __) => Center(child: Text('menu.pdf_load_failed'.tr)),
        ),
      ),
    );
  }
}
