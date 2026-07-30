import 'package:blog_site/constants/app_color.dart';
import 'package:blog_site/router/routes.dart';
import 'package:blog_site/widgets/auth/auth_card.dart';
import 'package:blog_site/widgets/auth/auth_header.dart';
import 'package:blog_site/widgets/auth/auth_side_panel.dart';
import 'package:blog_site/widgets/auth/auth_text_field.dart';
import 'package:blog_site/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your email and password.'),
          ),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await ProfileService.ensureProfileForCurrentUser();

      if (mounted) {
        context.go(Routes.home);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildLoginCard() {
    return AuthCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const AuthHeader(
            title: "Welcome Back",
          ),

          const SizedBox(height: 35),

          AuthTextField(
            controller: _emailController,
            label: "Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onSubmitted: _isLoading ? null : (_) => { _login() },
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: primaryColor,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword =
                        !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [

              Checkbox(
                value: _rememberMe,
                activeColor: primaryColor,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value!;
                  });
                },
              ),

              const Text("Remember me"),

              const Spacer(),

              TextButton(
                onPressed: () {
                  // Forgot Password
                },
                child: const Text(
                  "Forgot Password?",
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton(
              onPressed:
                  _isLoading ? null : _login,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              const Text(
                "Don't have an account?",
              ),

              TextButton(
                onPressed: () {
                  context.go(Routes.register);
                },
                child: const Text(
                  "Create one",
                ),
              ),
            ],
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
            backgroundColor:
                const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(24),
                  child: _buildLoginCard(),
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
                  color:
                      const Color(0xFFF8FAFC),
                  child: Center(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.all(
                        40,
                      ),
                      child: _buildLoginCard(),
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