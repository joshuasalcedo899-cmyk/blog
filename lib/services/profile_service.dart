import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static SupabaseClient get _client => Supabase.instance.client;
  static User? get currentUser => _client.auth.currentUser;
  static const String _avatarBucket = 'profile_avatars';

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
          profileId: existingProfile['id']?.toString(),
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
    String? profileId,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    final resolvedProfileId = profileId ?? user?.id;

    if (resolvedProfileId == null || resolvedProfileId.isEmpty) {
      throw StateError('No authenticated user found.');
    }

    final payload = <String, dynamic>{
      'id': resolvedProfileId,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    return _client
        .from('profiles')
        .upsert(payload, onConflict: 'id')
        .select()
        .single();
  }

  static String? _storagePathFromPublicUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      return null;
    }

    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf(_avatarBucket);
    if (bucketIndex == -1 || bucketIndex + 1 >= segments.length) {
      return segments.isEmpty ? null : Uri.decodeFull(segments.last);
    }

    return Uri.decodeFull(segments.sublist(bucketIndex + 1).join('/'));
  }

  static Future<String> uploadAvatarImage(
    XFile image, {
    String? previousAvatarUrl,
  }) async {
    final bytes = await image.readAsBytes();
    final fileName = '${DateTime.now().microsecondsSinceEpoch}_${image.name}';

    await _client.storage.from(_avatarBucket).uploadBinary(fileName, bytes);

    final imageUrl = _client.storage.from(_avatarBucket).getPublicUrl(fileName);

    if (previousAvatarUrl != null && previousAvatarUrl.trim().isNotEmpty) {
      final previousPath = _storagePathFromPublicUrl(previousAvatarUrl);
      if (previousPath != null && previousPath.isNotEmpty) {
        try {
          await _client.storage.from(_avatarBucket).remove([previousPath]);
        } catch (_) {
          // Keep the new avatar even if the old file cannot be removed.
        }
      }
    }

    return imageUrl;
  }
}
