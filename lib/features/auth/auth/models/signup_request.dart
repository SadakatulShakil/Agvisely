/// Payload collected on the sign-up screen and sent with Request OTP.
class SignupRequest {
  final String name;
  final String profession;
  final String district;
  final String upazila;
  final String phone; // canonical 01XXXXXXXXX

  const SignupRequest({
    required this.name,
    required this.profession,
    required this.district,
    required this.upazila,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'profession': profession,
        'district': district,
        'upazila': upazila,
        'phone': phone,
      };
}
