import 'package:blog_site/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:blog_site/constants/app_color.dart';
import 'package:go_router/go_router.dart';
import 'package:blog_site/services/auth_service.dart';

class NavBarItem extends StatelessWidget {
  final String route;
  const NavBarItem(this.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child : Row(
        children: <Widget> [
          IconButton(
                    style: IconButton.styleFrom(backgroundColor: buttonColor2, foregroundColor: Colors.white, ),
                    icon: Icon(Icons.person),
                    onPressed: () {context.go(route);},
        ),
        SizedBox(width: 10,),
        IconButton(onPressed: () async {
          try {
            await AuthService().logout();

            if (!context.mounted) return;

            

            context.go(Routes.login);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to logout: $e'),
              ),
            );
            debugPrint("Failed to logout: $e");
          }
        }, 
        icon: Icon(Icons.logout))
        ]
      ),
    );
  }
}