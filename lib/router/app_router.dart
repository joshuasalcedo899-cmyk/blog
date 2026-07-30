import 'package:blog_site/router/routes.dart';
import 'package:blog_site/views/create_blog/create_blog.dart';
import 'package:blog_site/views/home/home_view.dart';
import 'package:blog_site/views/profile/profile_view.dart';
import 'package:blog_site/views/profile/profile-edit_view.dart';
import 'package:blog_site/views/read_blog/read_blog.dart';
import 'package:go_router/go_router.dart';
import 'package:blog_site/views/main_layout.dart';
import 'package:blog_site/views/login/login_view.dart';
import 'package:blog_site/views/landing/landing_view.dart';
import 'package:blog_site/views/register/register_view.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: Routes.root,
      builder: (context, state) => const LandingView(),
    ),

    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginView(),
    ),

    GoRoute(
      path: Routes.register,
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
          path: Routes.home,
          builder: (context, state) => const HomeView(),
        ),

        GoRoute(
          path: Routes.profile,
          builder: (context, state) => const ProfileView(),
        ),

        GoRoute(
          path: Routes.profileEdit,
          builder: (context, state) => const ProfileEditView(),
        ),

        GoRoute(
          path: Routes.createBlog,
          builder: (context, state) => const CreateBlogView(),
        ),

        GoRoute(
          path: Routes.readBlog(),
          builder: (context, state) {
            final postId = state.pathParameters['postId'] ?? '';
            return ReadBlogView(postId: postId);
          },
        ),
      ],
    ),
  ],
);
