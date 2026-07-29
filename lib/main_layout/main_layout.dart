import 'package:blog_site/widgets/centered_view/centered_view.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:blog_site/widgets/navigation_bar/navigation_bar.dart';
import 'package:blog_site/widgets/navigation_drawer/navigation_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          drawer: sizingInformation.deviceScreenType == DeviceScreenType.mobile
              ? const NavDrawer()
              : null,

          backgroundColor: Colors.white,

          body: Column(
            children: [
              const NavBar(), // Full width

              Expanded(
                child: CenteredView(
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}