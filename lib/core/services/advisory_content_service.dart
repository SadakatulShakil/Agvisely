import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../models/advisory_content_model.dart';

/// Advisory body for a picked stage — demo-JSON-backed for now.
class AdvisoryContentService {
  AdvisoryContentService._internal();
  static final AdvisoryContentService _instance = AdvisoryContentService._internal();
  factory AdvisoryContentService() => _instance;

  /// `content` is non-null on success. `error` is a human-readable message
  /// on failure.
  Future<({AdvisoryContentModel? content, String? error})> fetch(
    int categoryId,
    int itemId,
    int stageId,
  ) async {
    try {
      final raw = await rootBundle.loadString('assets/json/advisory_content_demo.json');
      // TODO(api): replace the line above with a GET to
      //   /advisory/categories/{categoryId}/items/{itemId}/stages/{stageId}/content
      //   via ApiClient (same Authorization-bearer pattern as
      //   AdvisoryStagesService.fetch). Keep the SAME parsing below —
      //   decoded['data'] is the real API's shape too.

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) {
        return (content: null, error: 'Invalid response format received from the server.');
      }

      return (content: AdvisoryContentModel.fromJson(data), error: null);
    } catch (_) {
      return (content: null, error: 'Something went wrong while loading the advisory.');
    }
  }
}
