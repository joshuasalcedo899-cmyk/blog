import 'package:flutter/material.dart';
import 'package:blog_site/widgets/navigation_bar/navbar_logo.dart';
import 'package:blog_site/widgets/navigation_bar/navbar_item.dart';

class NavigationBarTabletDesktop extends StatelessWidget {
  const NavigationBarTabletDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  double.infinity,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: BorderSide.strokeAlignCenter),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const NavBarLogo(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const NavBarItem('/profile')
            ]
          )
        ],
      ),
    );
  }
}