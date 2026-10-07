import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../features/auth/auth/presentation/pages/login_page.dart';
import '../services/user_pref_service.dart';
import 'api_endpoints.dart';
import 'network_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 8);

  // Shared across concurrent 401s so five requests failing at once trigger
  // one refresh call, not five.
  Future<String?>? _refreshFuture;

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

  Future<dynamic> get(String url, {Map<String, String>? headers}) =>
      _send('GET', url, headers: headers);

  Future<dynamic> post(String url, {dynamic body, Map<String, String>? headers}) =>
      _send('POST', url, body: body, headers: headers);

  Future<dynamic> _send(
    String method,
    String url, {
    dynamic body,
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      final finalHeaders = _getHeaders(extraHeaders: headers);

      _logRequest(method, url, finalHeaders, body: body);

      final response = method == 'GET'
          ? await _client.get(uri, headers: finalHeaders).timeout(_timeout)
          : await _client
              .post(uri, headers: finalHeaders, body: jsonEncode(body))
              .timeout(_timeout);

      _logResponse(url, response.statusCode, response.body);

      // Session-expired path: only for requests that were actually
      // authenticated (carried a Bearer token) — a 401 on a public
      // endpoint (login/signup/professions) is just a normal error.
      if (response.statusCode == 401 && finalHeaders.containsKey('Authorization')) {
        if (!isRetry) {
          final newToken = await _refreshAccessToken();
          if (newToken != null) {
            final retryHeaders = Map<String, String>.from(headers ?? {});
            retryHeaders['Authorization'] = 'Bearer $newToken';
            return _send(method, url, body: body, headers: retryHeaders, isRetry: true);
          }
        }
        // Refresh failed, or the retried request is still 401 — the
        // session is unrecoverable.
        await _forceLogout();
      }

      // Must await (not just return the Future) — _processResponse is
      // now async (JSON decode can hop to compute()); an un-awaited
      // return here would let its exceptions bypass this catch block.
      return await _processResponse(response);
    } catch (e) {
      _logError(url, e);
      throw NetworkExceptions.getErrorMessage(e);
    }
  }

  /// Exchanges the stored refresh token for a new access token, shared
  /// across any concurrent 401s so only one refresh call ever happens at
  /// once. Returns null (and leaves the session untouched here — the
  /// caller forces logout) on any failure.
  Future<String?> _refreshAccessToken() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await UserPrefService().getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final resp = await post(
        ApiEndpoints.refreshTokenUrl,
        body: {'refreshToken': refreshToken},
      );
      final data = resp is Map ? resp['data'] : null;
      final newAccess = data is Map ? data['accessToken']?.toString() : null;
      if (newAccess == null || newAccess.isEmpty) return null;

      await UserPrefService().saveAccessToken(newAccess);
      final expiresIn = data is Map ? data['accessTokenExpiresIn'] : null;
      if (expiresIn is int) {
        await UserPrefService()
            .saveAccessTokenExpiry(DateTime.now().add(Duration(seconds: expiresIn)));
      }
      final newRefresh = data is Map ? data['refreshToken']?.toString() : null;
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await UserPrefService().saveRefreshToken(newRefresh);
      }
      return newAccess;
    } catch (_) {
      return null;
    }
  }

  Future<void> _forceLogout() async {
    await UserPrefService().clearSession();
    Get.offAll(() => const LoginPage());
  }

  /// Proactively refreshes the access token if it's close to expiring, so
  /// an authenticated request is far less likely to ever hit the reactive
  /// 401 path in [_send]. Call on app start/resume. Fails silently — a
  /// flaky network here just means the reactive path catches it on the
  /// next real request instead.
  Future<void> ensureValidToken() async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) return; // not logged in

    final expiry = UserPrefService().accessTokenExpiry;
    if (expiry == null) return; // unknown — let the reactive path handle it

    const buffer = Duration(minutes: 10);
    if (DateTime.now().isBefore(expiry.subtract(buffer))) return; // still fresh

    await _refreshAccessToken();
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
    }

    // Non-2xx: surface the server's own message where possible so callers
    // can show it straight in a snackbar via NetworkExceptions (it already
    // passes Strings through untouched).
    try {
      final decoded = await _decodeJson(body);
      final message = decoded is Map
          ? (decoded['message'] ?? decoded['error'])?.toString()
          : null;
      throw (message != null && message.isNotEmpty)
          ? message
          : 'Request failed (${response.statusCode})';
    } on FormatException {
      throw 'Request failed (${response.statusCode})';
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