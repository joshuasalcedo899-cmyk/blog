import 'package:blog_site/constants/app_color.dart';
import 'package:blog_site/features/auth/widgets/auth_card.dart';
import 'package:blog_site/features/auth/widgets/auth_header.dart';
import 'package:blog_site/features/auth/widgets/auth_side_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  Widget _buildLandingCard(BuildContext context) {
    return AuthCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AuthHeader(
            title: "Welcome to Travelog."
          ),
          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton(
              onPressed: () {
                context.go("/login");
              },
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              onPressed: () {
                context.go("/register");
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: buttonColor,
                side: const BorderSide(color: buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Sign Up",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        if (sizing.isMobile) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildLandingCard(context),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              const AuthSidePanel(),
              Expanded(
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: _buildLandingCard(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
