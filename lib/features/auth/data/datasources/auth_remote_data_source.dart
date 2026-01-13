import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quote_vault/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> login({required String email, required String password});

  Future<void> logout();

  Future<void> resetPassword(String email);

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get onAuthStateChanged;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'username': name},
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Signup failed: No user returned');
      }

      // Note: If email confirmation is ON, session will be null here.
      // We attempt a profile upsert, but the DB Trigger is the primary way.
      if (response.session != null) {
        try {
          await supabaseClient.from('profiles').upsert({
            'id': user.id,
            'username': name,
          });
          print('--- Profile created manually during signup ---');
        } catch (e) {
          print(
            '--- Profile upsert skipped (likely RLS or no session): $e ---',
          );
        }
      } else {
        print('--- Signup success: Email confirmation likely required ---');
      }

      return UserModel.fromSupabase(user, profile: {'username': name});
    } catch (e) {
      print('--- Signup Error: $e ---');
      rethrow;
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Login failed: Invalid response');
      }

      final profile = await _getUserProfile(response.user!.id);
      return UserModel.fromSupabase(response.user!, profile: profile);
    } catch (e) {
      print('--- Login Error: $e ---');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await supabaseClient.auth.resetPasswordForEmail(email);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;

    final profile = await _getUserProfile(user.id);
    return UserModel.fromSupabase(user, profile: profile);
  }

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return supabaseClient.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;

      final profile = await _getUserProfile(user.id);
      return UserModel.fromSupabase(user, profile: profile);
    });
  }

  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      final data = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return data;
    } catch (e) {
      return null;
    }
  }
}
