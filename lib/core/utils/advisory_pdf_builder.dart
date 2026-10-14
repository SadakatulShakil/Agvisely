import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/advisory_content_model.dart';
import '../../models/advisory_item_model.dart';
import '../../models/advisory_stage_model.dart';

class AdvisoryPdfBuilder {
  const AdvisoryPdfBuilder._();

  static Future<Uint8List> build({
    required AdvisoryItemModel item,
    required AdvisoryStageModel stage,
    required AdvisoryContentModel content,
    required String? categoryLabel,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(item.label(false), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text(stage.label(false), style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
          pw.SizedBox(height: 16),
          pw.Text(categoryLabel ?? '', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          for (final section in content.sections) ...[
            _section(section.label(false), section.bullets.map((b) => b.label(false)).toList()),
            pw.SizedBox(height: 12),
          ],
          if (content.goodPractice != null)
            _section(
              content.goodPractice!.label(false),
              content.goodPractice!.bullets.map((b) => b.label(false)).toList(),
            ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _section(String title, List<String> bullets) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        for (final bullet in bullets)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('•  ', style: const pw.TextStyle(fontSize: 11)),
                pw.Expanded(child: pw.Text(bullet, style: const pw.TextStyle(fontSize: 11))),
              ],
            ),
          ),
      ],
    );
  }
}
