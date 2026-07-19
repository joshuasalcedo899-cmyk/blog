import 'package:flutter/material.dart';
import 'package:blog_site/widgets/navigation_drawer/drawer_item.dart';
import 'package:blog_site/widgets/navigation_drawer/navigation_drawer_header.dart';


class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,)
          ],
          ),
          child: Column(
            children: <Widget>[
              NavigationDrawerHeader(),
              DrawerItem(title: 'Profile', icon: Icons.person),
              DrawerItem(title: 'About', icon: Icons.info),
            ]
          ),
      );
  }
}