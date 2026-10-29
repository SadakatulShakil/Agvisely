import 'dart:typed_data';

import 'package:bangla_pdf/bangla_pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/advisory_content_model.dart';
import '../../models/advisory_item_model.dart';
import '../../models/advisory_stage_model.dart';
import '../network/api_endpoints.dart';

class AdvisoryPdfBuilder {
  const AdvisoryPdfBuilder._();

  // Mirrors lib/core/theme/app_theme_colors.dart (AppColors) — PdfColor has
  // no shared type with Flutter's Color, so the palette is duplicated here.
  static final _primary = PdfColor.fromHex('#5F9E43');
  static final _primaryDark = PdfColor.fromHex('#678042');
  static final _navy = PdfColor.fromHex('#2E3F4F');
  static final _textSecondary = PdfColor.fromHex('#6B7A63');
  static final _textPrimary = PdfColor.fromHex('#1E2A18');
  static final _accent = PdfColor.fromHex('#9BB673');
  static final _dividerColor = PdfColor.fromHex('#E3E7E0');

  // A4 width (595.28pt) minus the 24pt margin set below on both sides.
  static const double _contentWidth = 547.0;

  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  /// Loads the bundled AnekBangla weights once and makes Regular the
  /// package-wide default so every `Text`/`Header`/bullet call below shapes
  /// with it unless a bold variant is passed explicitly.
  static Future<void> _ensureFonts() async {
    if (_regularFont != null && _boldFont != null) return;
    final regularBytes = await rootBundle.load('assets/fonts/AnekBangla-Regular.ttf');
    final boldBytes = await rootBundle.load('assets/fonts/AnekBangla-Bold.ttf');
    _regularFont = BanglaPdf.loadFont(regularBytes);
    _boldFont = BanglaPdf.loadFont(boldBytes);
    BanglaPdf.configure(defaultFont: _regularFont);
  }

  static Future<Uint8List> build({
    required AdvisoryItemModel item,
    required AdvisoryStageModel stage,
    required AdvisoryContentModel content,
    required String? categoryLabel,
    required bool isBn,
  }) async {
    await _ensureFonts();
    final cropImageBytes = await _fetchImageBytes(stage.icon ?? item.imageUrl);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.SizedBox(height: 14),
          _titleBlock(item: item, stage: stage, isBn: isBn),
          pw.SizedBox(height: 10),
          _headerImage(cropImageBytes),
          pw.SizedBox(height: 18),
          _titleRow(categoryLabel: categoryLabel, isBn: isBn),
          for (var i = 0; i < content.sections.length; i++) ...[
            pw.SizedBox(height: 16),
            ..._sectionWidgets(content.sections[i], isBn),
            if (i < content.sections.length - 1) ...[
              pw.SizedBox(height: 12),
              pw.Divider(color: _dividerColor, thickness: 1),
            ],
          ],
          if (content.goodPractice != null) ...[
            pw.SizedBox(height: 18),
            ..._goodPracticeWidgets(content.goodPractice!, isBn),
          ],
        ],
      ),
    );

    return doc.save();
  }

  /// Crop name + stage name as plain text above the image, not overlaid on
  /// it — legibility shouldn't depend on how dark or busy a given item's
  /// photo happens to be.
  static pw.Widget _titleBlock({
    required AdvisoryItemModel item,
    required AdvisoryStageModel stage,
    required bool isBn,
  }) {
    final cropPrefix = isBn ? 'ফসল' : 'Crop';
    final stagePrefix = isBn ? 'পর্যায়' : 'Stage';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        Text('$cropPrefix: ${item.label(isBn)}', fontSize: 20, banglaFont: _boldFont, color: _navy),
        pw.SizedBox(height: 3),
        Text('$stagePrefix: ${stage.label(isBn)}', fontSize: 12, color: _textSecondary),
      ],
    );
  }

  static pw.Widget _headerImage(Uint8List? imageBytes) {
    return pw.ClipRRect(
      horizontalRadius: 12,
      verticalRadius: 12,
      child: pw.Container(
        width: _contentWidth,
        height: 320,
        color: _accent,
        child: imageBytes != null
            ? pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.contain)
            : null,
      ),
    );
  }

  static pw.Widget _titleRow({required String? categoryLabel, required bool isBn}) {
    final label =
        (categoryLabel != null && categoryLabel.isNotEmpty) ? categoryLabel : (isBn ? 'ফসল পরামর্শ' : 'Crop Advisory');
    return pw.Row(
      children: [
        pw.Container(
          width: 24,
          height: 24,
          decoration: pw.BoxDecoration(
            color: _tintOnWhite(_primary, 0.12),
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(child: Text(label, fontSize: 16, banglaFont: _boldFont, color: _primary)),
      ],
    );
  }

  static List<pw.Widget> _sectionWidgets(AdvisorySectionModel section, bool isBn) {
    final title = section.label(isBn);
    return [
      if (title.isNotEmpty) ...[
        Text(title, fontSize: 13, banglaFont: _boldFont, color: _navy),
        pw.SizedBox(height: 6),
      ],
      for (final bullet in section.bullets) _bulletRow(bullet.label(isBn)),
    ];
  }

  /// Flat list (like [_sectionWidgets]), not one composite boxed widget —
  /// `MultiPage` can only break *between* top-level items it's given, not
  /// inside one; a single Stack/Container holding the title + every bullet
  /// can't be split, so a good-practice section with enough bullets to
  /// exceed one page's height on its own used to crash pagination outright.
  /// The tinted background is now just the header row's own decoration
  /// (small, bounded height) instead of washing the whole card.
  static List<pw.Widget> _goodPracticeWidgets(AdvisorySectionModel section, bool isBn) {
    return [
      pw.Container(
        width: _contentWidth,
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: pw.BoxDecoration(
          color: _tintOnWhite(_primaryDark, 0.14),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        ),
        child: pw.Row(
          children: [
            pw.Container(
              width: 22,
              height: 22,
              decoration: const pw.BoxDecoration(color: PdfColors.white, shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: Text(section.label(isBn), fontSize: 14, banglaFont: _boldFont, color: _primaryDark),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 10),
      for (final bullet in section.bullets) _bulletRow(bullet.label(isBn)),
    ];
  }

  /// `PdfColor`'s alpha channel is dropped for solid fills in this `pdf`
  /// version (`setFillColor` only ever writes RGB) — this blends [base] onto
  /// white at [alpha] to get an equivalent OPAQUE tint instead.
  static PdfColor _tintOnWhite(PdfColor base, double alpha) => PdfColor(
        1 - (1 - base.red) * alpha,
        1 - (1 - base.green) * alpha,
        1 - (1 - base.blue) * alpha,
      );

  static pw.Widget _bulletRow(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: pw.BoxDecoration(color: _textSecondary, shape: pw.BoxShape.circle),
          ),
          pw.Expanded(child: Text(text, fontSize: 11, color: _textPrimary)),
        ],
      ),
    );
  }

  static Future<Uint8List?> _fetchImageBytes(String? relativeUrl) async {
    if (relativeUrl == null || relativeUrl.isEmpty) return null;
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrlUserHost}$relativeUrl');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) return resp.bodyBytes;
    } catch (_) {
      // Fall through to the neutral placeholder.
    }
    return null;
  }
}
