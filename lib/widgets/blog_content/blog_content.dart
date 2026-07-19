import 'package:flutter/material.dart';

class BlogContent extends StatelessWidget {
  const BlogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('SHARE YOUR STORY', style: TextStyle(height: 0.9, fontWeight: FontWeight.w800, fontSize: 80),),
          SizedBox(height: 30),
          Text('This is the content of the blog post. It can be multiple paragraphs long and contain various information about the topic being discussed.', 
          style: TextStyle(
            fontSize: 21, 
            height: 1.7)
          ),
        ],
      ),
    );
  }
}