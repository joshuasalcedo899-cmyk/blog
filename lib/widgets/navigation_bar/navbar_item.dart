import 'package:flutter/material.dart';
import 'package:blog_site/constants/app_color.dart';
import 'package:go_router/go_router.dart';

class NavBarItem extends StatelessWidget {
  final String route;
  const NavBarItem(this.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
                style: IconButton.styleFrom(backgroundColor: buttonColor2, foregroundColor: Colors.white, ),
                icon: Icon(Icons.person),
                onPressed: () {context.go(route);},
    );
  }
}