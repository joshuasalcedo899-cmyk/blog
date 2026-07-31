import 'package:flutter/material.dart';
import 'package:blog_site/constants/app_color.dart';
import 'package:go_router/go_router.dart';

class PostBlogMobile extends StatelessWidget {
  final String title;
  const PostBlogMobile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.pop();
        context.go('/create_blog');
        },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        overlayColor: primaryColor,
      ),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
    );
  }
}