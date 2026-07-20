import 'package:blog_site/views/about/about_view.dart';
import 'package:blog_site/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'views/home/home_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
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
        )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Blog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

