import 'package:flutter/material.dart';
import 'package:blog_site/widgets/blog_content/blog_content.dart';
import 'package:blog_site/widgets/post_blog/post_blog.dart';

class HomeContentDesktop extends StatelessWidget {
  const HomeContentDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
              BlogContent(),
              Expanded(
                child: Center(
                  child: PostBlog(
                    title: 'Post a Blog Now!',
                  )
                )
              )
            ]);
  }
}