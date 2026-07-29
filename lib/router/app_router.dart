import 'package:blog_site/views/create_blog/create_blog.dart';
import 'package:blog_site/views/home/home_view.dart';
import 'package:blog_site/views/profile/profile_view.dart';
import 'package:blog_site/views/read_blog/read_blog.dart';
import 'package:go_router/go_router.dart';
import 'package:blog_site/main_layout/main_layout.dart';
import 'package:blog_site/features/auth/view/login_view.dart';
import 'package:blog_site/features/auth/view/landing_view.dart';
import 'package:blog_site/features/auth/view/register_view.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingView(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),

    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(
          child: child,
        );
      },

      routes: [

        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeView(),
        ),

        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileView(),
        ),

        GoRoute(
          path: '/create_blog',
          builder: (context, state) => const CreateBlogView(),
        ),

        GoRoute(
          path: '/read_blog/:postId',
          builder: (context, state) {
            final postId = state.pathParameters['postId'] ?? '';
            return ReadBlogView(postId: postId);
          },
        ),
      ],
    ),
  ],
);
