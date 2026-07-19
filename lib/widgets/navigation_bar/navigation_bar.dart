import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:blog_site/widgets/navigation_bar/navbar_mobile.dart';
import 'package:blog_site/widgets/navigation_bar/navbar_tablet_desktop.dart';


class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => NavBarMobile(),
      desktop: (context) => NavigationBarTabletDesktop(),
    );
}
}