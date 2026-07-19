import 'package:flutter/material.dart';
import 'package:blog_site/widgets/blog_content/blog_content.dart';
import 'package:blog_site/widgets/post_blog/post_blog.dart';

class HomeContentMobile extends StatelessWidget {
  const HomeContentMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        BlogContent(),
        SizedBox(height: 100,),
        PostBlog(
          title: 'Post a Blog Now!',
        )
      ],
     );
  }
} 