import 'package:auth_flow_app/core/error/exceptions.dart';
import 'package:auth_flow_app/core/network/supabase/auth_client.dart';
import 'package:auth_flow_app/features/auth/data/datasources/email_auth_datasource.dart';
import 'package:auth_flow_app/features/auth/data/models/user_model.dart';

class EmailAuthDataSourceImpl implements EmailAuthDataSource {
  final AuthClient _authClient;

  EmailAuthDataSourceImpl(this._authClient);

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final authResponse = await _authClient.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (authResponse.user == null) {
        throw AuthException('Failed to sign up');
      }
      return UserModel.fromSupabaseUser(authResponse.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmail({required String email, required String password}) async {
    try {
      final authResponse = await _authClient.signInWithEmail(email: email, password: password);
      if (authResponse.user == null) {
        throw AuthException('Failed to sign in');
      }
      return UserModel.fromSupabaseUser(authResponse.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _authClient.resetPassword(email: email);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to reset password: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> verifyOtp({required String otp, required String email}) async {
    try {
      final authResponse = await _authClient.verifyOtp(otp: otp, email: email);
      if (authResponse.user == null) {
        throw AuthException('Failed to verify otp');
      }
      return UserModel.fromSupabaseUser(authResponse.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to verify email: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    try {
      await _authClient.updatePassword(password: password);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update password: ${e.toString()}');
    }
  }

  @override
  Future<void> sendMagicLink({required String email}) async {
    try {
      await _authClient.sendMagicLink(email: email);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update password: ${e.toString()}');
    }
  }
}
