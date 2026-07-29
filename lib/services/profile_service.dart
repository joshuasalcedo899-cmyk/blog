import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static SupabaseClient get _client => Supabase.instance.client;
  static User? get currentUser => _client.auth.currentUser;

  static String _displayNameFromUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final rawName = metadata['name'];

    if (rawName is String && rawName.trim().isNotEmpty) {
      return rawName.trim();
    }

    final email = user.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'User';
  }

  static Future<Map<String, dynamic>?> fetchProfileByEmail(
    String email,
  ) async {
    return _client.from('profiles').select().eq('email', email).maybeSingle();
  }

  static Future<Map<String, dynamic>?> fetchProfileById(
    String profileId,
  ) async {
    return _client.from('profiles').select().eq('id', profileId).maybeSingle();
  }

  static Future<Map<String, dynamic>?> fetchCurrentProfile() async {
    final user = _client.auth.currentUser;
    final email = user?.email?.trim();

    if (user == null || email == null || email.isEmpty) {
      return null;
    }

    return fetchProfileByEmail(email);
  }

  static Future<Map<String, dynamic>> ensureProfileForCurrentUser() async {
    final user = _client.auth.currentUser;
    final email = user?.email?.trim();

    if (user == null || email == null || email.isEmpty) {
      throw StateError('No authenticated user found.');
    }

    final existingProfile = await fetchProfileByEmail(email);
    if (existingProfile != null) {
      final existingName = existingProfile['name']?.toString().trim();
      if (existingName == null || existingName.isEmpty) {
        return saveProfile(
          profileId: (existingProfile['id'] as num).toInt(),
          name: _displayNameFromUser(user),
          email: email,
          avatarUrl: existingProfile['avatar_url']?.toString(),
        );
      }

      return existingProfile;
    }

    return saveProfile(
      name: _displayNameFromUser(user),
      email: email,
    );
  }

  static Future<Map<String, dynamic>> saveProfile({
    int? profileId,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (profileId == null) {
      return _client.from('profiles').insert(payload).select().single();
    }

    return _client
        .from('profiles')
        .update(payload)
        .eq('id', profileId)
        .select()
        .single();
  }
}
