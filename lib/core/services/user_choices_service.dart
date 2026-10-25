import 'package:get/get.dart';
import '../../models/user_choice_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/network_exceptions.dart';
import 'user_pref_service.dart';

/// The "My Choice" page's data source — `GET/POST /user-choices`,
/// `DELETE /user-choices/{id}`. Always hits the network (no cache): this is
/// the user's own curated list, so it should always reflect the server's
/// current state rather than something stale.
class UserChoicesService {
  UserChoicesService._internal();
  static final UserChoicesService _instance = UserChoicesService._internal();
  factory UserChoicesService() => _instance;

  /// `choices` is non-null (possibly empty) on success. `error` is a
  /// human-readable message on failure so the caller can show it directly.
  Future<({List<UserChoiceModel>? choices, String? error})> fetch() async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (choices: null, error: 'error.login_again'.tr);
    }

    try {
      final resp = await ApiClient().get(
        ApiEndpoints.userChoices,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! List) {
        return (choices: null, error: 'error.invalid_response'.tr);
      }

      final choices = data
          .whereType<Map>()
          .map((e) => UserChoiceModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (choices: choices, error: null);
    } catch (e) {
      return (choices: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }

  /// The backend upserts by (categoryId, itemId) — adding a pair that's
  /// already saved just returns the existing entry rather than erroring or
  /// duplicating it.
  Future<({UserChoiceModel? choice, String? error})> add({
    required int categoryId,
    required int itemId,
  }) async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (choice: null, error: 'error.login_again'.tr);
    }

    try {
      final resp = await ApiClient().post(
        ApiEndpoints.userChoices,
        body: {'categoryId': categoryId, 'itemId': itemId},
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp is Map ? resp['data'] : null;
      if (data is! Map) {
        return (choice: null, error: 'error.invalid_response'.tr);
      }
      return (choice: UserChoiceModel.fromJson(data.cast<String, dynamic>()), error: null);
    } catch (e) {
      return (choice: null, error: NetworkExceptions.getErrorMessage(e));
    }
  }

  /// `error` is null on success.
  Future<({bool success, String? error})> remove(int id) async {
    final token = await UserPrefService().getAccessToken();
    if (token == null || token.isEmpty) {
      return (success: false, error: 'error.login_again'.tr);
    }

    try {
      await ApiClient().delete(
        ApiEndpoints.userChoice(id),
        headers: {'Authorization': 'Bearer $token'},
      );
      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: NetworkExceptions.getErrorMessage(e));
    }
  }
}
