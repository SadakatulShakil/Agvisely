/// Payload collected on the sign-up screen and sent with Request OTP.
class SignupRequest {
  final String name;
  final int professionId;
  final String phone; // canonical 01XXXXXXXXX

  const SignupRequest({
    required this.name,
    required this.professionId,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'professionId': professionId,
      };
}
