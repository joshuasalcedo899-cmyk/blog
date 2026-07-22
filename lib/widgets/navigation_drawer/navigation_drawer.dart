import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              context.pop();
              context.go("/");
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              context.pop();
              context.go("/profile");
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("About"),
            onTap: () {
              context.pop();
              context.go("/about");
            },
          ),
            ]
          ),
      );
  }
}