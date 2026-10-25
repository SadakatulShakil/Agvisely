import 'dart:io';
import 'dart:async';

import 'package:get/get.dart';

class NetworkExceptions {
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'error.no_internet'.tr;
    } else if (error is TimeoutException) {
      return 'error.timeout'.tr;
    } else if (error is FormatException) {
      return 'error.invalid_response'.tr;
    } else if (error is HttpException) {
      return 'error.server_connection'.tr;
    } else if (error is String) {
      return error;
    } else {
      return 'error.unexpected_network'.tr;
    }
  }
}