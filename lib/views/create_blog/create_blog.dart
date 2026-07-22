import 'dart:io';

import 'package:blog_site/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateBlogView extends StatefulWidget {
  const CreateBlogView({super.key});

  @override
  State<CreateBlogView> createState() => _CreateBlogViewState();
}

class _CreateBlogViewState extends State<CreateBlogView> {
  final ImagePicker _picker = ImagePicker();

  final List<XFile> selectedImages = [];

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Blog",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: "Share your thoughts...",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                style: FilledButton.styleFrom(overlayColor: const Color.fromARGB(255, 16, 92, 153), backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5))),
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text("Add Photos"),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: selectedImages.map((image) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(image.path),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            color: Colors.white,
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                selectedImages.remove(image);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              Container(
                alignment: Alignment.center,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                    backgroundColor: primaryColor, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(5),)),
                  onPressed: () {
                    // Upload to Supabase
                  },
                  child: const Text("Publish Blog", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}