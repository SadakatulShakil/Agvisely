import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'api_endpoints.dart'; // Updated import

enum NetworkState { loading, online, offline }

class NetworkController extends GetxController {
  var networkState = NetworkState.loading.obs;
  var networkMessage = ''.obs;
  var networkStatus = 'Checking network...'.obs;
  var networkIcon = Icons.wifi_off.obs;

  /// Bumped each time connectivity is confirmed restored after being
  /// offline — widgets showing a broken-image fallback (home category
  /// icons, My Choice icons) watch this via `Obx` and fold it into their
  /// `Image`'s key, so regaining connectivity forces a fresh load attempt
  /// instead of leaving the earlier failure on screen until something else
  /// happens to rebuild them.
  final reconnectedAt = 0.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// `true` only once a check has actually run and come back negative —
  /// during the brief `loading` window right after app start this is
  /// `false` so an early request isn't wrongly short-circuited.
  bool get isOffline => networkState.value == NetworkState.offline;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 300), _initNetworkCheck);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        _updateStatus(result);
      },
    );
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  Future<void> checkConnection() async {
    await _initNetworkCheck();
  }

  Future<void> _initNetworkCheck() async {
    // Not set to `loading` here — _updateStatus needs the still-current
    // state first to tell a reconnect apart from a fresh/initial check.
    final result = await Connectivity().checkConnectivity();
    await _updateStatus(result);
  }

  Future<void> _updateStatus(List<ConnectivityResult> result) async {
    final wasOffline = networkState.value == NetworkState.offline;
    networkState.value = NetworkState.loading;

    if (result.contains(ConnectivityResult.wifi)) {
      networkStatus.value = 'Wi-Fi connected';
      networkIcon.value = Icons.wifi;
    } else if (result.contains(ConnectivityResult.mobile)) {
      networkStatus.value = 'Mobile data connected';
      networkIcon.value = Icons.network_cell;
    } else if (result.contains(ConnectivityResult.ethernet)) {
      networkStatus.value = 'Ethernet connected';
      networkIcon.value = Icons.settings_ethernet;
    } else {
      networkStatus.value = 'No network';
      networkIcon.value = Icons.wifi_off;
      networkState.value = NetworkState.offline;
      networkMessage.value = 'No internet';
      return;
    }

    await _checkInternetAccess(wasOffline);
  }

  Future<void> _checkInternetAccess(bool wasOffline) async {
    final urlsToTry = [
      ApiEndpoints.checkNetwork, // Using our new Endpoints file
      'https://www.google.com/generate_204',
      'https://1.1.1.1',
    ];

    bool hasInternet = false;

    for (final url in urlsToTry) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 204 ||
            response.statusCode == 200 ||
            response.statusCode == 301) {
          hasInternet = true;
          break;
        }
      } catch (_) {}
    }

    if (hasInternet) {
      networkState.value = NetworkState.online;
      networkMessage.value = 'Internet working';
      if (wasOffline) reconnectedAt.value++;
    } else {
      _setOffline('No internet access');
    }
  }

  void _setOffline(String message) {
    networkState.value = NetworkState.offline;
    networkMessage.value = message;
  }
}