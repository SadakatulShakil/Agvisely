import 'package:get/get.dart';

import '../../../../core/services/professions_service.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../models/profession_model.dart';
import '../../../../models/user_model.dart';

/// Profile screen state. Renders from the cached user/profession instantly
/// (no loading spinner), then silently refreshes from `GET /users/me` (and
/// the professions catalog, if not already cached) in the background and
/// swaps in the fresh data if it differs.
class ProfileController extends GetxController {
  final user = Rxn<UserModel>();
  final profession = Rxn<ProfessionModel>();

  @override
  void onInit() {
    super.onInit();
    user.value = UserPrefService().cachedUser;
    _resolveProfession();
    _refresh();
  }

  Future<void> _refresh() async {
    final fresh = await UserPrefService().refreshCurrentUser();
    if (fresh != null) user.value = fresh;
    _resolveProfession();
  }

  /// Called by AuthController right after a successful login/signup so a
  /// permanent ProfileController left over from a previous session shows
  /// the new user immediately instead of the old one.
  void applyUser(UserModel newUser) {
    user.value = newUser;
    _resolveProfession();
  }

  void _resolveProfession() {
    final professionId = user.value?.professionId;
    if (professionId == null) return;

    final cached = ProfessionsService().byId(professionId);
    if (cached != null) {
      profession.value = cached;
      return;
    }

    ProfessionsService().fetch().then((list) {
      if (user.value?.professionId != professionId) return; // stale by the time it lands
      profession.value =
          list?.firstWhereOrNull((p) => p.id == professionId);
    });
  }
}
