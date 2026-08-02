import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  static final supabase = Supabase.instance.client;

  static String? _storagePathFromPublicUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      return null;
    }

    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf('post_images');
    if (bucketIndex == -1 || bucketIndex + 1 >= segments.length) {
      return segments.isEmpty ? null : Uri.decodeFull(segments.last);
    }

    return Uri.decodeFull(segments.sublist(bucketIndex + 1).join('/'));
  }

  static Future<Map<String, dynamic>> _uploadPostImage({
    required String postId,
    required XFile image,
  }) async {
    final bytes = await image.readAsBytes();
    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_${image.name}';

    await supabase.storage
        .from('post_images')
        .uploadBinary(fileName, bytes);

    final imageUrl = supabase.storage
        .from('post_images')
        .getPublicUrl(fileName);

    final row = await supabase.from('post_images').insert({
      'post_id': postId,
      'image_url': imageUrl,
    }).select().single();

    return Map<String, dynamic>.from(row as Map);
  }

  static Future<String> createPost({
    required String title,
    required String content,
    required String subtitle,
    required List<XFile> images,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    // Create the post and get its ID
    final post = await supabase
        .from('posts')
        .insert({
          'title': title,
          'content': content,
          'subtitle': subtitle,
          'user_id': user.id,
        })
        .select()
        .single();

    final String postId = post['id'].toString();

    // Upload images and save their URLs
    for (final image in images) {
      await _uploadPostImage(postId: postId, image: image);
    }

    return postId;
  }

  static Future<Map<String, dynamic>?> fetchPostById(String postId) async {
    return supabase.from('posts').select().eq('id', postId).maybeSingle();
  }

  static Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String title,
    required String content,
    required String subtitle,
  }) async {
    return supabase
        .from('posts')
        .update({
          'title': title,
          'content': content,
          'subtitle': subtitle,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', postId)
        .select()
        .single();
  }

  static Future<List<Map<String, dynamic>>> addPostImages({
    required String postId,
    required List<XFile> images,
  }) async {
    final uploadedImages = <Map<String, dynamic>>[];

    for (final image in images) {
      uploadedImages.add(await _uploadPostImage(postId: postId, image: image));
    }

    return uploadedImages;
  }

  static Future<void> deletePostImage({
    required String imageId,
    String? imageUrl,
  }) async {
    final storagePath = _storagePathFromPublicUrl(imageUrl);

    if (storagePath != null && storagePath.isNotEmpty) {
      try {
        await supabase.storage.from('post_images').remove([storagePath]);
      } catch (_) {
        // Keep going so the database row can still be removed.
      }
    }

    await supabase.from('post_images').delete().eq('id', imageId);
  }

  static Future<List<Map<String, dynamic>>> fetchFeedPosts({
    int? limit,
  }) async {
    final query = supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    final List<dynamic> rows = limit == null ? await query : await query.limit(limit);

    return rows.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchRecentPosts({
    int limit = 12,
  }) {
    return fetchFeedPosts(limit: limit);
  }

  static Future<List<Map<String, dynamic>>> fetchPostsByUserId(
    String userId,
  ) async {
    final List<dynamic> rows = await supabase
        .from('posts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchPostImagesByPostId(
    String postId,
  ) async {
    final List<dynamic> rows = await supabase
        .from('post_images')
        .select()
        .eq('post_id', postId)
        .order('created_at');

    return rows.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchCommentsByPostId(
    String postId,
  ) async {
    final List<dynamic> rows = await supabase
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    return rows.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createComment({
    required String postId,
    required String content,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw StateError('User not logged in.');
    }

    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError('Comment cannot be empty.');
    }

    return supabase.from('comments').insert({
      'post_id': postId,
      'user_id': user.id,
      'content': trimmedContent,
    }).select().single();
  }

  static Future<Map<String, dynamic>> updateComment({
    required String commentId,
    required String content,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw StateError('User not logged in.');
    }

    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError('Comment cannot be empty.');
    }

    return supabase
        .from('comments')
        .update({
          'content': trimmedContent,
        })
        .eq('id', commentId)
        .select()
        .single();
  }

  static Future<Map<String, dynamic>?> fetchPostDetail(String postId) async {
    final post = await fetchPostById(postId);
    if (post == null) {
      return null;
    }

    final images = await fetchPostImagesByPostId(postId);
    return <String, dynamic>{
      'post': post,
      'images': images,
    };
  }
}
