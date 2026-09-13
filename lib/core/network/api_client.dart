import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'network_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 8);

  Map<String, String> _getHeaders({Map<String, String>? extraHeaders}) {
    final lang = Get.locale?.languageCode ?? 'bn';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': lang,
    };
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final finalHeaders = _getHeaders(extraHeaders: headers);

      _logRequest('GET', url, finalHeaders);

      final response = await _client.get(uri, headers: finalHeaders).timeout(_timeout);

      _logResponse(url, response.statusCode, response.body);
      // Must await (not just return the Future) — _processResponse is
      // now async (JSON decode can hop to compute()); an un-awaited
      // return here would let its exceptions bypass this catch block.
      return await _processResponse(response);
    } catch (e) {
      _logError(url, e);
      throw NetworkExceptions.getErrorMessage(e);
    }
  }

  Future<dynamic> post(String url, {dynamic body, Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final finalHeaders = _getHeaders(extraHeaders: headers);

      _logRequest('POST', url, finalHeaders, body: body);

      final response = await _client
          .post(uri, headers: finalHeaders, body: jsonEncode(body))
          .timeout(_timeout);

      _logResponse(url, response.statusCode, response.body);
      // Must await (not just return the Future) — _processResponse is
      // now async (JSON decode can hop to compute()); an un-awaited
      // return here would let its exceptions bypass this catch block.
      return await _processResponse(response);
    } catch (e) {
      _logError(url, e);
      throw NetworkExceptions.getErrorMessage(e);
    }
  }

  // Large payloads (forecast is the biggest response in the app) decode
  // off the main isolate so jsonDecode can't block the raster/UI threads
  // mid pull-to-refresh (observed as dropped video frames). Tiny payloads
  // (live weather ~300B) skip compute() — spawning an isolate for them
  // costs more than it saves.
  Future<dynamic> _decodeJson(String body) {
    return body.length > 50 * 1024
        ? compute(jsonDecode, body)
        : Future.value(jsonDecode(body));
  }

  Future<dynamic> _processResponse(http.Response response) async {
    final body = response.body.trim();

    // ── Guard: HTML response masquerading as 200 ──────────
    if (body.startsWith('<')) {
      log("🔴 [API] HTML response received instead of JSON: ${response.request?.url}");
      throw Exception('Server returned HTML instead of JSON');
    }

    // ── Guard: empty body ─────────────────────────────────
    if (body.isEmpty) {
      throw Exception('Empty response body');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await _decodeJson(body);
    } else {
      try {
        return await _decodeJson(body);
      } catch (_) {
        return {'statusCode': response.statusCode, 'error': response.reasonPhrase};
      }
    }
  }

  // --- Logging Helpers ---
  void _logRequest(String method, String url, Map headers, {dynamic body}) {
    log("🔵 [API] $method: $url");
    if (body != null) log("   Body: $body");
  }

  void _logResponse(String url, int statusCode, String body) {
    log("🟢 [API] $statusCode: $url");
    log("   Response: ${body.length > 300 ? '${body.substring(0, 300)}...' : body}");
  }

  void _logError(String url, dynamic error) {
    log("🔴 [API] ERROR: $url \n   Details: $error");
  }
}