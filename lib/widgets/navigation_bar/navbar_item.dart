import 'package:flutter/material.dart';
import 'package:blog_site/constants/app_color.dart';
import 'package:go_router/go_router.dart';

class NavBarItem extends StatelessWidget {
  final String title;
  final String route;
  const NavBarItem(this.title, this.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
                style: TextButton.styleFrom(overlayColor: primaryColor, foregroundColor: Colors.black, ),
                child: Text(
                  title, style: TextStyle(fontSize: 18)), onPressed: () {context.go(route);},);
  }
}