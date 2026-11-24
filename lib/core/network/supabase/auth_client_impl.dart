import 'package:auth_flow_app/core/network/supabase/auth_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthClientImpl implements AuthClient {
  final GoTrueClient goTrueClient;
  AuthClientImpl(this.goTrueClient);

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await goTrueClient.signUp(email: email, password: password, data: {'display_name': displayName});
  }

  @override
  Future<AuthResponse> signInWithEmail({required String email, required String password}) async {
    return await goTrueClient.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await goTrueClient.resetPasswordForEmail(email);
  }

  @override
  Future<AuthResponse> verifyOtp({required String otp, required String email}) async {
    return await goTrueClient.verifyOTP(token: otp, type: OtpType.recovery, email: email);
  }

  @override
  Future<UserResponse> updatePassword({required String password}) async {
    return await goTrueClient.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> sendMagicLink({required String email}) {
    // TODO: implement sendMagicLink
    throw UnimplementedError();
  }
}
