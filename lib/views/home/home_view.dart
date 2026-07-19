import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:blog_site/widgets/navigation_bar/navigation_bar.dart';
import 'package:blog_site/widgets/centered_view/centered_view.dart';
import 'package:blog_site/views/home/home_content_mobile.dart';
import 'package:blog_site/views/home/home_content_desktop.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CenteredView(
        child: Column(
          children: <Widget>[
            const NavBar(),
            Expanded(child: ScreenTypeLayout.builder(
              mobile: (context) => HomeContentMobile(),
              desktop: (context) => HomeContentDesktop(),
            ))
          ],
        ),
      ),
    );
  }
}