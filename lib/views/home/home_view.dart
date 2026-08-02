import 'package:blog_site/constants/app_color.dart';
import 'package:blog_site/services/create_service.dart';
import 'package:blog_site/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final Future<_HomeFeedData> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = _loadFeed();
  }

  Future<_HomeFeedData> _loadFeed() async {
    final posts = await PostService.fetchFeedPosts();

    final authorIds = posts
        .map((post) => post['user_id']?.toString())
        .where((value) => value != null && value.isNotEmpty)
        .cast<String>()
        .toSet();

    final profileEntries = await Future.wait(
      authorIds.map((authorId) async {
        try {
          return MapEntry(
            authorId,
            await ProfileService.fetchProfileById(authorId),
          );
        } catch (_) {
          return MapEntry<String, Map<String, dynamic>?>(authorId, null);
        }
      }),
    );
    final profiles = <String, Map<String, dynamic>?>{
      for (final entry in profileEntries) entry.key: entry.value,
    };

    final feedPosts = await Future.wait(
      posts.map((post) async {
        final postId = _stringValue(post['id']);
        final authorId = _stringValue(post['user_id']);

        List<Map<String, dynamic>> images = [];
        try {
          images = await PostService.fetchPostImagesByPostId(postId);
        } catch (_) {
          images = const <Map<String, dynamic>>[];
        }

        return _HomePostItem(
          post: post,
          author: authorId.isEmpty ? null : profiles[authorId],
          thumbnailUrl: images.isNotEmpty
              ? _stringValue(images.first['image_url'])
              : '',
        );
      }),
    );

    final authorCards = <String, _HomeProfileCard>{};
    for (final post in posts) {
      final authorId = _stringValue(post['user_id']);
      if (authorId.isEmpty) {
        continue;
      }

      final profile = profiles[authorId];
      if (profile == null) {
        continue;
      }

      final existing = authorCards[authorId];
      if (existing == null) {
        authorCards[authorId] = _HomeProfileCard(
          profile: profile,
          postCount: 1,
          latestPostId: _stringValue(post['id']),
          latestPostTitle: _stringValue(post['title'], fallback: 'Untitled'),
        );
      } else {
        existing.postCount += 1;
      }
    }

    final profilesList = authorCards.values.toList()
      ..sort((left, right) => right.postCount.compareTo(left.postCount));

    return _HomeFeedData(
      posts: feedPosts,
      profiles: profilesList,
    );
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
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
          Icon(icon, size: 18, color: primaryColor),
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

  Widget _buildPostCard(_HomePostItem item) {
    final post = item.post;
    final author = item.author;
    final postId = _stringValue(post['id']);
    final title = _stringValue(post['title'], fallback: 'Untitled');
    final subtitle = _stringValue(post['subtitle']);
    final content = _stringValue(post['content']);
    final authorName = _stringValue(author?['name']);
    final authorEmail = _stringValue(author?['email']);
    final authorAvatar = _stringValue(author?['avatar_url']);
    final createdAt = _formatDate(post['created_at']);
    final readTime = _readTime(content);
    final excerpt = subtitle.isNotEmpty
        ? subtitle
        : (content.isEmpty
            ? 'A new post from the feed.'
            : content.replaceAll('\n', ' ').split(' ').take(28).join(' '));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: postId.isEmpty ? null : () => context.go('/read_blog/$postId'),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5ECF4)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(14, 15, 23, 42),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 210,
                child: item.thumbnailUrl.isNotEmpty
                    ? Image.network(
                        item.thumbnailUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPostFallback(),
                      )
                    : _buildPostFallback(),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFE2E8F0),
                          backgroundImage:
                              authorAvatar.isNotEmpty ? NetworkImage(authorAvatar) : null,
                          child: authorAvatar.isNotEmpty
                              ? null
                              : const Icon(Icons.person, color: Colors.grey),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName.isNotEmpty ? authorName : 'Unknown author',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (authorEmail.isNotEmpty)
                                Text(
                                  authorEmail,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                            ],
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
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      excerpt,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildStatChip(
                          'Read time',
                          '$readTime min',
                          Icons.schedule_outlined,
                        ),
                        _buildStatChip(
                          'Author',
                          authorName.isNotEmpty ? authorName : 'Reader',
                          Icons.person_outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostFallback() {
    return Container(
      width: double.infinity,
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
      child: const Center(
        child: Icon(
          Icons.article_outlined,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildFeedSection(_HomeFeedData data) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Feed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${data.posts.length}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'All published posts from every user, ordered by newest first.',
            style: TextStyle(color: Color(0xFF64748B)),
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
                'No published blogs are available yet.',
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
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPostCard(item),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(_HomeProfileCard card) {
    final profile = card.profile;
    final profileName = _stringValue(profile['name'], fallback: 'Unknown writer');
    final profileEmail = _stringValue(profile['email']);
    final profileAvatar = _stringValue(profile['avatar_url']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage:
                    profileAvatar.isNotEmpty ? NetworkImage(profileAvatar) : null,
                child: profileAvatar.isNotEmpty
                    ? null
                    : const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (profileEmail.isNotEmpty)
                      Text(
                        profileEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Published ${card.postCount} blog${card.postCount == 1 ? '' : 's'} in the feed.',
            style: const TextStyle(
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Latest: ${card.latestPostTitle}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: buttonColor2,
              foregroundColor: Colors.white,
            ),
            onPressed: card.latestPostId.isEmpty
                ? null
                : () => context.go('/read_blog/${card.latestPostId}'),
            child: const Text('Open latest post'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilesSection(_HomeFeedData data) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Writer Profiles',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Writers who are publishing posts on the platform.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          if (data.profiles.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No other user profiles to show yet.',
                style: TextStyle(
                  color: Color(0xFF475569),
                  height: 1.6,
                ),
              ),
            )
          else
            Column(
              children: data.profiles
                  .map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildProfileCard(card),
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
    return FutureBuilder<_HomeFeedData>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(
            child: Text('Nothing to show yet.'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              ScreenTypeLayout.builder(
                mobile: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFeedSection(data),
                      const SizedBox(height: 20),
                      _buildProfilesSection(data),
                    ],
                  );
                },
                tablet: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFeedSection(data),
                      const SizedBox(height: 20),
                      _buildProfilesSection(data),
                    ],
                  );
                },
                desktop: (context) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: _buildFeedSection(data),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: _buildProfilesSection(data),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeFeedData {
  final List<_HomePostItem> posts;
  final List<_HomeProfileCard> profiles;

  const _HomeFeedData({
    required this.posts,
    required this.profiles,
  });
}

class _HomePostItem {
  final Map<String, dynamic> post;
  final Map<String, dynamic>? author;
  final String thumbnailUrl;

  const _HomePostItem({
    required this.post,
    required this.author,
    required this.thumbnailUrl,
  });
}

class _HomeProfileCard {
  final Map<String, dynamic> profile;
  int postCount;
  final String latestPostId;
  final String latestPostTitle;

  _HomeProfileCard({
    required this.profile,
    required this.postCount,
    required this.latestPostId,
    required this.latestPostTitle,
  });
}
