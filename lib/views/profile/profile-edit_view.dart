import 'dart:typed_data';

import 'package:blog_site/constants/app_color.dart';
import 'package:blog_site/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileEditView> {
  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;
  String? _profileId;
  String? _profileAvatarUrl;
  bool _isLoadingProfile = true;
  bool _isSavingProfile = false;

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

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

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.fetchCurrentProfile();
      final currentUser = ProfileService.currentUser;

      if (!mounted) return;

      setState(() {
        final fallbackEmail = currentUser?.email?.trim() ?? '';
        final fallbackName =
            currentUser?.userMetadata?['name']?.toString().trim() ??
                '';
        final fallbackAvatar =
            currentUser?.userMetadata?['avatar_url']?.toString().trim() ??
                '';

        final email =
            profile?['email']?.toString().trim() ?? fallbackEmail;
        final name =
            profile?['name']?.toString().trim() ?? fallbackName;
        final avatarUrl =
            profile?['avatar_url']?.toString().trim() ??
                fallbackAvatar;

        _profileId = profile?['id']?.toString();
        _profileAvatarUrl = avatarUrl;

        _nameController.text = name;
        _emailController.text = email;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_isSavingProfile) {
      return;
    }

    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name and email are required."),
        ),
      );
      return;
    }

    setState(() {
      _isSavingProfile = true;
    });

    try {
      String? avatarUrlToSave = _profileAvatarUrl;

      if (selectedImage != null) {
        avatarUrlToSave = await ProfileService.uploadAvatarImage(
          selectedImage!,
          previousAvatarUrl: _profileAvatarUrl,
        );
      }

      final savedProfile = await ProfileService.saveProfile(
        profileId: _profileId,
        name: name,
        email: email,
        avatarUrl: avatarUrlToSave,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profileId = savedProfile['id']?.toString();
        _profileAvatarUrl = savedProfile['avatar_url']?.toString().trim() ??
            avatarUrlToSave;
        selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated."),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProfile = false;
        });
      }
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

          _buildAvatarSection(),

          const SizedBox(height: 24),

          TextField(
            controller: _nameController,
            decoration: _editorDecoration("Full Name"),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _emailController,
            decoration: _editorDecoration("Email"),
          ),

          const SizedBox(height: 30),

          Row(
            children: [

              Expanded(
                child: FilledButton.icon(
                  onPressed: _isLoadingProfile || _isSavingProfile
                      ? null
                      : _saveProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isSavingProfile
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text("Save Changes"),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/profile'),
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
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final currentAvatar = _profileAvatarUrl?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatarPreview(),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedImage == null
                      ? (currentAvatar.isEmpty
                          ? 'Add a photo to make your profile feel more personal.'
                          : 'Update your current profile photo anytime.')
                      : 'New avatar selected. Save changes to apply it.',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _isLoadingProfile || _isSavingProfile
                          ? null
                          : _pickImage,
                      style: FilledButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(
                        currentAvatar.isEmpty ? 'Add avatar' : 'Change avatar',
                      ),
                    ),
                    if (selectedImage != null)
                      OutlinedButton.icon(
                        onPressed: _isLoadingProfile || _isSavingProfile
                            ? null
                            : () {
                                setState(() {
                                  selectedImage = null;
                                });
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFD0D7E2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text('Remove selection'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPreview() {
    final selected = selectedImage;
    final currentAvatar = _profileAvatarUrl?.trim() ?? '';

    Widget child;

    if (selected != null) {
      child = FutureBuilder<Uint8List>(
        future: selected.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              width: 76,
              height: 76,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: 76,
            height: 76,
          );
        },
      );
    } else if (currentAvatar.isNotEmpty) {
      child = Image.network(
        currentAvatar,
        fit: BoxFit.cover,
        width: 76,
        height: 76,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: Colors.grey);
        },
      );
    } else {
      child = const Icon(Icons.person, color: Colors.grey, size: 32);
    }

    return Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF34495E),
            Color(0xFF76D7C4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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

                    // Responsive Layout
                    ScreenTypeLayout.builder(

                      // MOBILE
                      mobile: (BuildContext context) {
                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [

                            _buildProfileForm()
                          ],
                        );
                      },

                      // TABLET
                      tablet: (BuildContext context) {
                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [

                            _buildProfileForm()
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
