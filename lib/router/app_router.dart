import 'package:blog_site/views/create_blog/create_blog.dart';
import 'package:blog_site/views/home/home_view.dart';
import 'package:blog_site/views/profile/profile_view.dart';
import 'package:go_router/go_router.dart';
import 'package:blog_site/main_layout/main_layout.dart';
import 'package:blog_site/features/auth/view/login_view.dart';

final GoRouter appRouter = GoRouter(
  routes: [

    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(
          child: child,
        );
      },

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
          path: '/create_blog',
          builder: (context, state) => const CreateBlogView(),
        ),

        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginView(),
        ),
      ],
    ),
  ],
);