import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBarLogo extends StatelessWidget {
  const NavBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
            height: 80,
            width: 150,
            child: IconButton(icon: Image.asset('assets/Blog.png'), 
            style: ButtonStyle(overlayColor: WidgetStatePropertyAll(Colors.transparent),),
            onPressed: () {context.go("/");},),
            );
  }
}