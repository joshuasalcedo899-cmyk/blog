import 'package:blog_site/widgets/post_blog/post_blog.dart';
import 'package:flutter/material.dart';
import 'package:blog_site/constants/app_color.dart';

class NavigationDrawerHeader extends StatelessWidget {
  const NavigationDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: buttonColor2,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PostBlog(title: 'Post Blog')
        ],)
      );
  }
}