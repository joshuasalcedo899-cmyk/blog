import 'package:blog_site/constants/app_color.dart';
import 'package:blog_site/services/create_service.dart';
import 'package:blog_site/services/delete_service.dart';
import 'package:blog_site/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ReadBlogView extends StatefulWidget {
  final String postId;

  const ReadBlogView({
    super.key,
    required this.postId,
  });

  @override
  State<ReadBlogView> createState() => _ReadBlogViewState();
}

class _ReadBlogViewState extends State<ReadBlogView> {
  late Future<_ReadBlogData?> _detailFuture;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<_ReadBlogData?> _loadDetail() async {
    final detail = await PostService.fetchPostDetail(widget.postId);
    if (detail == null) {
      return null;
    }

    final post = detail['post'] as Map<String, dynamic>;
    final images = (detail['images'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final authorId = post['user_id']?.toString();
    final author = authorId == null || authorId.isEmpty
        ? null
        : await ProfileService.fetchProfileById(authorId);
    var comments = const <Map<String, dynamic>>[];
    var commentsEnabled = true;
    try {
      comments = await PostService.fetchCommentsByPostId(widget.postId);
    } catch (_) {
      commentsEnabled = false;
    }

    final commentProfiles = commentsEnabled
        ? await _loadCommentProfiles(comments)
        : <String, Map<String, dynamic>?>{};
    final commentItems = comments.map((comment) {
      final commentAuthorId = comment['user_id']?.toString();
      return _ReadCommentData(
        comment: comment,
        author: commentAuthorId == null || commentAuthorId.isEmpty
            ? null
            : commentProfiles[commentAuthorId],
      );
    }).toList();

    return _ReadBlogData(
      post: post,
      images: images,
      author: author,
      comments: commentItems,
      commentsEnabled: commentsEnabled,
    );
  }

  Future<Map<String, Map<String, dynamic>?>> _loadCommentProfiles(
    List<Map<String, dynamic>> comments,
  ) async {
    final authorIds = comments
        .map((comment) => comment['user_id']?.toString())
        .where((value) => value != null && value.isNotEmpty)
        .cast<String>()
        .toSet();

    final profiles = <String, Map<String, dynamic>?>{};
    for (final authorId in authorIds) {
      try {
        profiles[authorId] = await ProfileService.fetchProfileById(authorId);
      } catch (_) {
        profiles[authorId] = null;
      }
    }

    return profiles;
  }

  String _formatDate(dynamic value) {
    final parsed = value == null ? null : DateTime.tryParse(value.toString());
    if (parsed == null) {
      return 'Just now';
    }

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  String _buildSubtitle(Map<String, dynamic> post) {
    final storedSubtitle = _stringValue(post['subtitle']);
    if (storedSubtitle.isNotEmpty) {
      return storedSubtitle;
    }

    final content = _stringValue(post['content']);
    if (content.isEmpty) {
      return 'A fresh story from the blog editor.';
    }

    final normalized = content.replaceAll('\n', ' ');
    if (normalized.length <= 150) {
      return normalized;
    }

    return '${normalized.substring(0, 150).trim()}...';
  }

  int _readTime(String content) {
    final words = content
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;

    return words == 0 ? 1 : (words / 220).ceil();
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  Future<void> _submitComment() async {
    final currentUser = ProfileService.currentUser;
    if (currentUser == null) {
      if (!mounted) {
        return;
      }

      context.go('/login');
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      await PostService.createComment(
        postId: widget.postId,
        content: content,
      );

      _commentController.clear();
      if (!mounted) {
        return;
      }

      setState(() {
        _detailFuture = _loadDetail();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not post comment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    if (commentId.isEmpty) {
      return;
    }

    try {
      await DeleteService().deleteById(table: 'comments', id: commentId);

      if (!mounted) {
        return;
      }

      setState(() {
        _detailFuture = _loadDetail();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete comment: $error')),
      );
    }
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Widget _buildHero(
    BuildContext context,
    _ReadBlogData data,
    bool isMobile,
  ) {
    final images = data.images;
    final heroImage = images.isNotEmpty
        ? _stringValue(images.first['image_url'])
        : '';
    final subtitle = _buildSubtitle(data.post);
    final title = _stringValue(data.post['title'], fallback: 'Untitled');
    final content = _stringValue(data.post['content']);
    final authorName = _stringValue(data.author?['name']);
    final authorEmail = _stringValue(data.author?['email']);
    final authorAvatar = _stringValue(data.author?['avatar_url']);
    final hasAuthorAvatar = _hasText(authorAvatar);
    final displayAuthorName = _hasText(authorName)
        ? authorName
        : (_hasText(authorEmail) ? authorEmail : 'Unknown author');
    final createdAt = _formatDate(data.post['created_at']);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(35, 15, 23, 42),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: SizedBox(
        height: isMobile ? 420 : 520,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (heroImage.isNotEmpty)
              Image.network(
                heroImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _heroFallback();
                },
              )
            else
              _heroFallback(),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(220, 2, 6, 23),
                    Color.fromARGB(150, 15, 23, 42),
                    Color.fromARGB(35, 15, 23, 42),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 20 : 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        foregroundColor: Colors.white,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const Spacer(),
                      _heroChip(
                        icon: Icons.schedule_outlined,
                        label: '${_readTime(content)} min read',
                      ),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroChip(
                          icon: Icons.label_outline,
                          label: 'Blog post',
                        ),
                        const SizedBox(height: 18),
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 34 : 54,
                            fontWeight: FontWeight.w900,
                            height: 1.02,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: isMobile ? 16 : 18,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _heroChip(
                              icon: Icons.person_outline,
                              label: displayAuthorName,
                            ),
                            _heroChip(
                              icon: Icons.calendar_today_outlined,
                              label: createdAt,
                            ),
                            _heroChip(
                              icon: Icons.photo_library_outlined,
                              label: '${images.length} image${images.length == 1 ? '' : 's'}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasAuthorAvatar)
              Positioned(
                right: 20,
                bottom: 20,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  backgroundImage: NetworkImage(authorAvatar),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _heroFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _heroChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5ECF4)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(18, 15, 23, 42),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildImageGallery(List<Map<String, dynamic>> images) {
    final gallery = images.length > 1 ? images.sublist(1) : const <Map<String, dynamic>>[];

    if (gallery.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gallery',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: gallery.map((image) {
              final url = _stringValue(image['image_url']);
              return ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 180,
                  height: 130,
                  child: url.isEmpty
                      ? Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.image_outlined),
                        )
                      : Image.network(
                          url,
                          fit: BoxFit.cover,
                        ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(String content) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Story',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.8,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(_ReadBlogData data) {
    final post = data.post;
    final images = data.images;
    final author = data.author;
    final authorAvatar = _stringValue(author?['avatar_url']);
    final authorName = _stringValue(author?['name']);
    final authorEmail = _stringValue(author?['email']);
    final createdAt = _formatDate(post['created_at']);
    final content = _stringValue(post['content']);
    final title = _stringValue(post['title'], fallback: 'Untitled');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Post details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _detailRow('Title', title),
              const SizedBox(height: 12),
              _detailRow('Published', createdAt),
              const SizedBox(height: 12),
              _detailRow('Read time', '${_readTime(content)} min'),
              const SizedBox(height: 12),
              _detailRow('Photos', images.length.toString()),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Author',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE2E8F0),
                    backgroundImage:
                        authorAvatar.isNotEmpty ? NetworkImage(authorAvatar) : null,
                    child: authorAvatar.isNotEmpty
                        ? null
                        : const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName.isNotEmpty ? authorName : 'Unknown author',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authorEmail,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(_ReadBlogData data) {
    final comments = data.comments;
    final currentUser = ProfileService.currentUser;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${comments.length}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your thoughts and start the conversation.',
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          if (!data.commentsEnabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Comments are not available yet.',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (currentUser == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 520;

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign in to leave a comment.',
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Sign in'),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sign in to leave a comment.',
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign in'),
                      ),
                    ],
                  );
                },
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _commentController,
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: buttonColor2),
                    onPressed: _isSubmittingComment ? null : _submitComment,
                    icon: _isSubmittingComment
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: const Text('Post comment'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          if (comments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No comments yet. Be the first to share your thoughts.',
                style: TextStyle(
                  color: Color(0xFF475569),
                ),
              ),
            )
          else
            Column(
              children: comments
                  .map(
                    (commentData) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildCommentCard(commentData),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(_ReadCommentData data) {
    final comment = data.comment;
    final author = data.author;
    final currentUserId = ProfileService.currentUser?.id;
    final commentUserId = _stringValue(comment['user_id']);
    final canDelete = currentUserId != null && currentUserId == commentUserId;
    final authorName = _stringValue(author?['name']);
    final authorEmail = _stringValue(author?['email']);
    final authorAvatar = _stringValue(author?['avatar_url']);
    final createdAt = _formatDate(comment['created_at']);
    final commentId = _stringValue(comment['id']);
    final content = _stringValue(comment['content']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE2E8F0),
            backgroundImage:
                authorAvatar.isNotEmpty ? NetworkImage(authorAvatar) : null,
            child: authorAvatar.isNotEmpty
                ? null
                : const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        authorName.isNotEmpty ? authorName : 'Unknown reader',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      createdAt,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (authorEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    authorEmail,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  content,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              tooltip: 'Delete comment',
              onPressed: () => _deleteComment(commentId),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ReadBlogData?>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const Scaffold(
            body: Center(
              child: Text('Post not found.'),
            ),
          );
        }

        return ResponsiveBuilder(
          builder: (context, sizing) {
            final isMobile = sizing.isMobile;

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHero(context, data, isMobile),
                          const SizedBox(height: 24),
                          if (isMobile) ...[
                            _buildArticleCard(_stringValue(data.post['content'])),
                            const SizedBox(height: 20),
                            _buildImageGallery(data.images),
                            const SizedBox(height: 20),
                            _buildSidebar(data),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    children: [
                                      _buildArticleCard(_stringValue(data.post['content'])),
                                      const SizedBox(height: 20),
                                      _buildImageGallery(data.images),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 3,
                                  child: _buildSidebar(data),
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),
                          _buildCommentsSection(data),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ReadBlogData {
  final Map<String, dynamic> post;
  final List<Map<String, dynamic>> images;
  final Map<String, dynamic>? author;
  final List<_ReadCommentData> comments;
  final bool commentsEnabled;

  const _ReadBlogData({
    required this.post,
    required this.images,
    required this.author,
    required this.comments,
    required this.commentsEnabled,
  });
}

class _ReadCommentData {
  final Map<String, dynamic> comment;
  final Map<String, dynamic>? author;

  const _ReadCommentData({
    required this.comment,
    required this.author,
  });
}
