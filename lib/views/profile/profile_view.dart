import 'dart:typed_data';

import 'package:blog_site/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;

  final TextEditingController _nameController =
      TextEditingController(text: "Joshua Salcedo");

  final TextEditingController _usernameController =
      TextEditingController(text: "@joshua");

  final TextEditingController _emailController =
      TextEditingController(text: "joshua@email.com");

  final TextEditingController _bioController =
      TextEditingController(
        text:
            "Passionate Flutter developer focused on creating clean, responsive, and user-friendly applications.",
      );

  final TextEditingController _websiteController =
      TextEditingController(text: "https://portfolio.com");

  final TextEditingController _locationController =
      TextEditingController(text: "Laguna, Philippines");

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  InputDecoration _editorDecoration(
    String label, {
    String? hintText,
    int? maxLines,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: maxLines == null || maxLines == 1 ? 18 : 20,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:
            const BorderSide(color: Color(0xFFD8E0EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:
            const BorderSide(color: Color(0xFFD8E0EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.4,
        ),
      ),
      alignLabelWithHint:
          maxLines != null && maxLines > 1,
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE5ECF4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(
              18,
              15,
              23,
              42,
            ),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatChip(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: primaryColor,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return FutureBuilder<Uint8List?>(
      future: selectedImage?.readAsBytes(),
      builder: (context, snapshot) {
        Widget avatar;

        if (selectedImage == null) {
          avatar = const CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.grey,
            ),
          );
        } else if (!snapshot.hasData) {
          avatar = const CircleAvatar(
            radius: 55,
            child: CircularProgressIndicator(),
          );
        } else {
          avatar = CircleAvatar(
            radius: 55,
            backgroundImage:
                MemoryImage(snapshot.data!),
          );
        }

        return Column(
          children: [
            avatar,
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _pickImage,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor2,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.photo_camera_outlined,
              ),
              label: const Text(
                "Change Photo",
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildProfileHeader() {
    return _buildSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _usernameController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _bioController.text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Update your public profile information.",
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 28),

          LayoutBuilder(
            builder: (context, constraints) {
              bool desktop = constraints.maxWidth > 650;

              if (desktop) {
                return Column(
                  children: [

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: _editorDecoration("Full Name"),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            decoration: _editorDecoration("Username"),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration: _editorDecoration("Email"),
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            decoration: _editorDecoration("Location"),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [

                  TextField(
                    controller: _nameController,
                    decoration: _editorDecoration("Full Name"),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _usernameController,
                    decoration: _editorDecoration("Username"),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _emailController,
                    decoration: _editorDecoration("Email"),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _locationController,
                    decoration: _editorDecoration("Location"),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _websiteController,
            decoration: _editorDecoration(
              "Website",
              hintText: "https://example.com",
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _bioController,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: _editorDecoration(
              "Bio",
              hintText: "Tell readers about yourself...",
              maxLines: 5,
            ),
          ),

          const SizedBox(height: 30),

          Row(
            children: [

              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("Save Changes"),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(
                      color: Color(0xFFD0D7E2),
                    ),
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text("Change Password"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Profile Statistics",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 20),

              _buildStatChip(
                "Posts",
                "24",
                Icons.article_outlined,
              ),
              const SizedBox(height: 12),
              _buildStatChip(
                "Joined",
                "July 2026",
                Icons.calendar_today_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "About",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Manage your personal information, profile picture, and public details that other users can see on your profile.",
                style: TextStyle(
                  height: 1.7,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
    @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1240,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [

                    const SizedBox(height: 24),

                    // Header
                    _buildProfileHeader(),

                    const SizedBox(height: 24),

                    // Responsive Layout
                    ScreenTypeLayout.builder(

                      // MOBILE
                      mobile: (BuildContext context) {
                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [

                            _buildProfileForm(),

                            const SizedBox(height: 20),

                            _buildSidebar(),
                          ],
                        );
                      },

                      // TABLET
                      tablet: (BuildContext context) {
                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [

                            _buildProfileForm(),

                            const SizedBox(height: 20),

                            _buildSidebar(),
                          ],
                        );
                      },

                      // DESKTOP
                      desktop: (BuildContext context) {
                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Expanded(
                              flex: 7,
                              child: _buildProfileForm(),
                            ),

                            const SizedBox(width: 24),

                            Expanded(
                              flex: 3,
                              child: _buildSidebar(),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}