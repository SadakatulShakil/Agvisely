import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/services/custom_codes_service.dart';
import '../../../models/custom_code_model.dart';
import '../presentation/pages/pdf_viewer_page.dart';
import '../presentation/widgets/feedback_dialog.dart';
import 'controllers/menu_tree_controller.dart';

/// Shared tap behavior for a custom-code row on the Menu tab — the same
/// single page renders the root list and every drill-down level, so a node
/// behaves identically regardless of how deep it's nested. Only ever called
/// for a row `flattenCustomCodes` rendered as tappable, i.e. [node] has no
/// children loaded yet (anything with children is auto-expanded inline
/// instead — see `menu_rows.dart`).
///
/// - `'list'`: lazily fetches this node's children (`GET
///   /custom-codes/{id}`) — it had none in the response we already have —
///   then hands the now-populated node to [onOpenList], which swaps the
///   page's current node in place (no navigation).
/// - `'pdf'`: opens [CustomCodeModel.url] — externally in the system
///   browser when [CustomCodeModel.isExternal], else in-app via
///   [PdfViewerPage].
/// - `'dialog'`: opens the feedback-submission popup.
/// - anything else: no-op — its tap behavior isn't defined by this
///   backend contract.
Future<void> handleCustomCodeTap(
  CustomCodeModel node, {
  required void Function(CustomCodeModel node) onOpenList,
}) async {
  switch (node.type) {
    case 'list':
      await _openList(node, onOpenList: onOpenList);
    case 'pdf':
      await _openPdf(node);
    case 'dialog':
      await FeedbackDialog.show();
  }
}

Future<void> _openList(
  CustomCodeModel node, {
  required void Function(CustomCodeModel node) onOpenList,
}) async {
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );
  final result = await CustomCodesService().fetchNode(node.id);
  Get.back(); // close the loading indicator

  if (result.node == null) {
    Get.snackbar('common.error'.tr, result.error ?? '');
    return;
  }

  Get.find<MenuTreeController>().mergeFetchedNode(result.node!);
  onOpenList(result.node!);
}

Future<void> _openPdf(CustomCodeModel node) async {
  final rawUrl = node.url;
  if (rawUrl == null || rawUrl.isEmpty) return;

  final url =
      rawUrl.startsWith('http')
          ? rawUrl
          : '${ApiEndpoints.baseUrlUserHost}$rawUrl';

  if (node.isExternal) {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
    return;
  }

  final isBn = Get.locale?.languageCode == 'bn';
  Get.to(() => PdfViewerPage(title: node.label(isBn), url: url));
}
