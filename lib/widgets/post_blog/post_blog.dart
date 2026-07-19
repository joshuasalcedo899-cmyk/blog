import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:blog_site/widgets/post_blog/post_blog_mobile.dart';
import 'package:blog_site/widgets/post_blog/post_blog_tablet_desktop.dart';

class PostBlog extends StatelessWidget {
  final String title;
  const PostBlog({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => PostBlogMobile(title: title),
      desktop: (context) => PostBlogTabletDesktop(title: title),
    );
  }
}