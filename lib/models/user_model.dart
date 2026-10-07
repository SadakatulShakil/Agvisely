/// Logged-in user profile — shared shape between the verify-otp response's
/// embedded `data.user` and the standalone `GET /users/me` response.
class UserModel {
  final int id;
  final String name;
  final String phone;
  final int professionId;
  final bool isPhoneVerified;
  final String? preferredLanguage;
  final String? status;
  final String? role; // only present on /users/me, not verify-otp
  final String? profileUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.professionId,
    this.isPhoneVerified = false,
    this.preferredLanguage,
    this.status,
    this.role,
    this.profileUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as int,
        name: j['name']?.toString() ?? '',
        phone: j['phone']?.toString() ?? '',
        professionId: j['professionId'] as int,
        isPhoneVerified: j['isPhoneVerified'] == true,
        preferredLanguage: j['preferredLanguage']?.toString(),
        status: j['status']?.toString(),
        role: j['role']?.toString(),
        profileUrl: j['profileUrl']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'professionId': professionId,
        'isPhoneVerified': isPhoneVerified,
        'preferredLanguage': preferredLanguage,
        'status': status,
        'role': role,
        'profileUrl': profileUrl,
      };
}
