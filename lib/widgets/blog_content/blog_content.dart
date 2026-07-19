import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class BlogContent extends StatelessWidget {
  const BlogContent({super.key});

  @override
  Widget build(BuildContext context) {
      return ResponsiveBuilder(
        builder: (context, sizingInformation) {
          var textAlignment = sizingInformation.deviceScreenType == DeviceScreenType.desktop
              ? TextAlign.left
              : TextAlign.center;
          double titleSize = sizingInformation.deviceScreenType == DeviceScreenType.mobile
              ? 50
              : 80;
          double descriptionSize = sizingInformation.deviceScreenType == DeviceScreenType.mobile
              ? 16
              : 21;

          return SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('SHARE YOUR STORY', style: TextStyle(height: 0.9, fontWeight: FontWeight.w800, fontSize: titleSize),),
                SizedBox(height: 30),
                Text('This is the content of the blog post. It can be multiple paragraphs long and contain various information about the topic being discussed.', 
                style: TextStyle(
                  fontSize: descriptionSize, 
                  height: 1.7),
                  textAlign: textAlignment,
                ),
                
              ],
            ),
          );
        }
      );
  }
}