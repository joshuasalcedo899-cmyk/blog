import 'package:blog_site/widgets/centered_view/centered_view.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:blog_site/widgets/navigation_bar/navigation_bar.dart';
import 'package:blog_site/widgets/navigation_drawer/navigation_drawer.dart';
import 'package:flutter/material.dart';


class CreateBlogView extends StatelessWidget {
  const CreateBlogView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
          builder: (context, sizingInformation) => Scaffold(
            drawer: sizingInformation.deviceScreenType == DeviceScreenType.mobile
                ? NavDrawer()
                : null,
        backgroundColor: Colors.white,
        body: CenteredView(
          child: Column(
            children: <Widget>[
              const NavBar(),
              Text('Create Blog View'),
            ],
          ),
        ),
      ),
    ); 
  }
}