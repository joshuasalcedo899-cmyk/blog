import 'package:blog_site/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:blog_site/widgets/navigation_bar/navbar_logo.dart';
import 'package:blog_site/widgets/navigation_bar/navbar_item.dart';

class NavigationBarTabletDesktop extends StatelessWidget {
  const NavigationBarTabletDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const NavBarLogo(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const NavBarItem('About', '/about'),
              SizedBox(width: 60),
              const NavBarItem('Profile', '/profile'),
            ]
          )
        ],
      ),
    );
  }
}