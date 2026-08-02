import 'package:blog_site/services/auth_service.dart';
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
              context.go("/home");
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
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              try{
                await AuthService().logout();

                if (!context.mounted) return;
                context.pop();
                context.go("/login");
              }
              catch (e){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to logout: $e'),
                  ),
                );
                debugPrint("Failed to logout: $e");
              }
            },
          ),
            ]
          ),
      );
  }
}