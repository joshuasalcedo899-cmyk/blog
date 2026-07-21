import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:blog_site/views/home/home_content_mobile.dart';
import 'package:blog_site/views/home/home_content_desktop.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: ScreenTypeLayout.builder(
            mobile: (context) => HomeContentMobile(),
            desktop: (context) => HomeContentDesktop(),
      )
    );
  }
}