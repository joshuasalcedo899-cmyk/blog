import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  static final supabase = Supabase.instance.client;

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
      final bytes = await image.readAsBytes();

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      await supabase.storage
          .from('post_images')
          .uploadBinary(fileName, bytes);

      final imageUrl = supabase.storage
          .from('post_images')
          .getPublicUrl(fileName);

      await supabase.from('post_images').insert({
        'post_id': postId,
        'image_url': imageUrl,
      });
    }

    return postId;
  }

  static Future<Map<String, dynamic>?> fetchPostById(String postId) async {
    return supabase.from('posts').select().eq('id', postId).maybeSingle();
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
