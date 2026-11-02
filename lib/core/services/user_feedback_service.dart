import 'package:get/get.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/network_exceptions.dart';
import 'user_pref_service.dart';

/// Sends a free-text feedback message — `POST /user-feedback`, triggered by
/// a `'dialog'`-type node in the Menu tab's `GET /custom-codes` tree.
class UserFeedbackService {
  UserFeedbackService._internal();
  static final UserFeedbackService _instance = UserFeedbackService._internal();
  factory UserFeedbackService() => _instance;

  /// `success` is true when the message was sent. `error` is a
  /// human-readable message on failure. [message] is trimmed and capped at
  /// 1000 characters before sending, matching the backend's contract.
  Future<({bool success, String? error})> submit(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return (success: false, error: 'menu.feedback_message_required'.tr);
    }
    final body = trimmed.length > 1000 ? trimmed.substring(0, 1000) : trimmed;

    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (success: false, error: 'error.login_again'.tr);
    }

    try {
      await ApiClient().post(
        ApiEndpoints.userFeedback,
        body: {'message': body},
        headers: {'Authorization': 'Bearer $token'},
      );
      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: NetworkExceptions.getErrorMessage(e));
    }
  }
}
