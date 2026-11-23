import 'package:auth_flow_app/core/network/supabase/auth_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthClientImpl implements AuthClient {
  final GoTrueClient goTrueClient;
  AuthClientImpl(this.goTrueClient);

  @override
  Future<AuthResponse> signUp({required String email, required String password, required String displayName}) async {
    return await goTrueClient.signUp(email: email, password: password, data: {'display_name': displayName});
  }
}
