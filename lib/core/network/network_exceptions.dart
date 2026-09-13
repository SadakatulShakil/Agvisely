import 'dart:io';
import 'dart:async';

class NetworkExceptions {
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is TimeoutException) {
      return 'Connection timed out. The server took too long to respond.';
    } else if (error is FormatException) {
      return 'Invalid response format received from the server.';
    } else if (error is HttpException) {
      return 'Server connection error occurred.';
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected network error occurred.';
    }
  }
}