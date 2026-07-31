import 'package:blog_site/constants/app_color.dart';
import 'package:blog_site/services/create_service.dart';
import 'package:blog_site/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final Future<_ProfilePageData> _pageFuture;

  @override
  void initState() {
    super.initState();
    _pageFuture = _loadData();
  }

  Future<_ProfilePageData> _loadData() async {
    final currentUser = ProfileService.currentUser;
    final profileFuture = ProfileService.fetchCurrentProfile();
    final postsFuture = currentUser == null
        ? Future.value(<Map<String, dynamic>>[])
        : PostService.fetchPostsByUserId(currentUser.id);

    final profile = await profileFuture;
    final posts = await postsFuture;

    final fallbackEmail = currentUser?.email?.trim() ?? '';
    final fallbackName =
        currentUser?.userMetadata?['name']?.toString().trim() ?? '';
    final fallbackAvatar =
        currentUser?.userMetadata?['avatar_url']?.toString().trim() ?? '';

    final email = profile?['email']?.toString().trim() ?? fallbackEmail;
    final name = profile?['name']?.toString().trim() ?? fallbackName;
    final avatarUrl =
        profile?['avatar_url']?.toString().trim() ?? fallbackAvatar;

    return _ProfilePageData(
      profile: profile,
      posts: posts,
      name: name.isNotEmpty ? name : 'Unknown user',
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _formatDate(dynamic value) {
    final parsed = value == null ? null : DateTime.tryParse(value.toString());
    if (parsed == null) {
      return 'Joined recently';
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

  int _readTime(String content) {
    final words = content
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;

    return words == 0 ? 1 : (words / 220).ceil();
  }

  Widget _buildSectionCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
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

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: primaryColor,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(_ProfilePageData data) {
    final hasAvatar = data.avatarUrl.trim().isNotEmpty;

    return _buildSectionCard(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: const Color(0xFFE2E8F0),
                  backgroundImage:
                      hasAvatar ? NetworkImage(data.avatarUrl) : null,
                  child: hasAvatar
                      ? null
                      : const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Edit profile',
              onPressed: () => context.go('/profile-edit'),
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishedBlogCard(Map<String, dynamic> post) {
    final title = _stringValue(post['title'], fallback: 'Untitled');
    final subtitle = _stringValue(post['subtitle']);
    final content = _stringValue(post['content']);
    final postId = _stringValue(post['id']);
    final createdAt = _formatDate(post['created_at']);
    final readTime = _readTime(content);
    final excerpt = subtitle.isNotEmpty
        ? subtitle
        : (content.isEmpty
            ? 'A freshly published blog post.'
            : content.replaceAll('\n', ' ').split(' ').take(24).join(' '));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: postId.isEmpty ? null : () => context.go('/read_blog/$postId'),
        child: Container(
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildStatChip(
                          'Published',
                          createdAt,
                          Icons.calendar_today_outlined,
                        ),
                        _buildStatChip(
                          'Read time',
                          '$readTime min',
                          Icons.schedule_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: buttonColor2,
                  foregroundColor: Colors.white,
                ),
                onPressed:
                    postId.isEmpty ? null : () => context.go('/read_blog/$postId'),
                child: const Text('Open'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPublishedBlogsSection(_ProfilePageData data) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Published Blogs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'These are the blog posts you have published.',
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          if (data.posts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'You have not published any blogs yet.',
                style: TextStyle(
                  color: Color(0xFF475569),
                  height: 1.6,
                ),
              ),
            )
          else
            Column(
              children: data.posts
                  .map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildPublishedBlogCard(post),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfilePageData>(
      future: _pageFuture,
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
              child: Text('Profile not found.'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(data),
                      const SizedBox(height: 24),
                      ScreenTypeLayout.builder(
                        mobile: (context) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPublishedBlogsSection(data),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                        tablet: (context) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPublishedBlogsSection(data),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                        desktop: (context) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _buildPublishedBlogsSection(data),
                              ),
                              const SizedBox(width: 24),
                            ],
                          );
                        },
                      ),
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
  }
}

class _ProfilePageData {
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> posts;
  final String name;
  final String email;
  final String avatarUrl;

  const _ProfilePageData({
    required this.profile,
    required this.posts,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });
}
