import 'package:flutter/material.dart';
import 'package:blog_site/constants/app_color.dart';

class PostBlogTabletDesktop extends StatelessWidget {
  final String title;
  const PostBlogTabletDesktop({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container( 
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        title, 
        style: const TextStyle(fontSize: 18,
        fontWeight: FontWeight.w800),),
    );
  }
}