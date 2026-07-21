import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blog_site/constants/app_color.dart';

class PostBlogTabletDesktop extends StatelessWidget {
  final String title;
  const PostBlogTabletDesktop({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go('/create_blog'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        overlayColor: primaryColor,
      ),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        );
  }
}