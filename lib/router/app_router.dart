import 'package:blog_site/views/about/about_view.dart';
import 'package:blog_site/views/create_blog/create_blog.dart';
import 'package:blog_site/views/home/home_view.dart';
import 'package:blog_site/views/profile/profile_view.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileView(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutView(),
    ),
    GoRoute(
      path: '/create_blog',
      builder: (context, state) => const CreateBlogView(),
    ),
  ],
);