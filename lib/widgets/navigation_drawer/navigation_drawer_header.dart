import 'package:flutter/material.dart';
import 'package:blog_site/constants/app_color.dart';

class NavigationDrawerHeader extends StatelessWidget {
  const NavigationDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: primaryColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Share Your Story Now!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          )
        ],)
      );
  }
}