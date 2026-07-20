import 'package:flutter/material.dart';
import 'package:blog_site/widgets/navigation_bar/navbar_item.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final String route;
  final IconData icon;
  const DrawerItem({super.key, required this.title, required this.route, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 60),
      child: Row(
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: 30),
          NavBarItem(title, route),
        ],
      ),
    );
  }
}