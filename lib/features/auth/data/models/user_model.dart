import 'package:quote_vault/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.avatarUrl,
  });

  factory UserModel.fromSupabase(User user, {Map<String, dynamic>? profile}) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: profile?['username'] ?? '',
      avatarUrl: profile?['avatar_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': name,
      'avatar_url': avatarUrl,
    };
  }
}
