import 'package:flutter/material.dart';

class PostBlogMobile extends StatelessWidget {
  final String title;
  const PostBlogMobile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(title, 
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800),
        ),
    );
  }
}