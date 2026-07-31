import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blog_site/constants/app_color.dart';

class PostBlogTabletDesktop extends StatelessWidget {
  final String title;
  const PostBlogTabletDesktop({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.go('/create_blog'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        overlayColor: buttonColor2,
      ),
      label: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      icon: Icon(Icons.add),
        );
  }
}