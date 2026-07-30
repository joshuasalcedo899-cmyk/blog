import 'dart:typed_data';
import 'package:blog_site/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:blog_site/services/create_service.dart';

class CreateBlogView extends StatefulWidget {
  const CreateBlogView({super.key});

  @override
  State<CreateBlogView> createState() => _CreateBlogViewState();
}


class _CreateBlogViewState extends State<CreateBlogView> {

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _excerptController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  final List<XFile> selectedImages = <XFile>[];

  bool _isPublishing = false;


  @override
  void dispose() {
    _titleController.dispose();
    _excerptController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(XFile image) {
    setState(() {
      selectedImages.remove(image);
    });
  }

  Future<void> _publishPost() async {
    if (_isPublishing) {
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    final title = _titleController.text.trim();
    final subtitle = _excerptController.text.trim();
    final content = _bodyController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Title and content are required."),
          ),
        );
      }

      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
      return;
    }

    try {
      final postId = await PostService.createPost(
        title: title,
        subtitle: subtitle,
        content: content,
        images: selectedImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Post published!"),
          ),
        );
        context.go('/read_blog/$postId');
      }
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
          _isPublishing = false;
        });
      }
    }
  }

  int get _wordCount {
    final String text = _bodyController.text.trim();
    if (text.isEmpty) {
      return 0;
    }

    return text.split(RegExp(r'\s+')).where((String word) => word.isNotEmpty).length;
  }

  int get _readTime {
    if (_wordCount == 0) {
      return 1;
    }

    return (_wordCount / 220).ceil();
  }

  InputDecoration _editorDecoration(String label, {String? hintText, int? maxLines}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF64748B)),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: maxLines == null || maxLines == 1 ? 18 : 20,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8E0EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8E0EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primaryColor, width: 1.4),
      ),
      alignLabelWithHint: maxLines != null && maxLines > 1,
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5ECF4)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(18, 15, 23, 42),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEFF6FF),
              const Color(0xFFF8FAFC).withValues(alpha: 0.98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(18, 15, 23, 42),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.image_outlined,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cover image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upload a cover photo to make your post feel polished and complete.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _pickImages,
                    style: FilledButton.styleFrom(
                      backgroundColor: buttonColor2,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Add photos'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile image) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        final Widget child;

        if (!snapshot.hasData) {
          child = Container(
            width: 180,
            height: 128,
            alignment: Alignment.center,
            color: const Color(0xFFF1F5F9),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          );
        } else {
          child = Image.memory(
            snapshot.data!,
            width: 180,
            height: 128,
            fit: BoxFit.cover,
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              child,
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: const Color.fromARGB(170, 15, 23, 42),
                  borderRadius: BorderRadius.circular(999),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                    iconSize: 16,
                    color: Colors.white,
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeImage(image),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditorPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Story details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                decoration: _editorDecoration('Title', hintText: 'Write a compelling headline'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _excerptController,
                onChanged: (_) => setState(() {}),
                maxLines: 3,
                decoration: _editorDecoration(
                  'Subtitle',
                  hintText: 'Summarize the post in one or two clear sentences',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                onChanged: (_) => setState(() {}),
                minLines: 10,
                maxLines: 16,
                decoration: _editorDecoration(
                  'Content',
                  hintText: 'Start writing your article here...',
                ),
              ),
              const SizedBox(height: 18),
              _buildCoverPlaceholder(),
              if (selectedImages.isNotEmpty) ...[
                const SizedBox(height: 18),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: selectedImages.map(_buildImagePreview).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
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
                'Publishing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              _buildStatChip('Words', '$_wordCount', Icons.notes_outlined),
              const SizedBox(height: 12),
              _buildStatChip('Read time', '$_readTime min', Icons.schedule_outlined),
              const SizedBox(height: 12),
              _buildStatChip('Photos', selectedImages.length.toString(), Icons.photo_library_outlined),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isPublishing ? null : _publishPost,
                style: FilledButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _isPublishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.schedule_send),
                label: const Text('Publish post'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFD0D7E2)),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save draft'),
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
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    ScreenTypeLayout.builder(
                      mobile: (BuildContext context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildEditorPanel(),
                          const SizedBox(height: 20),
                          _buildSidebar(),
                        ],
                      ),
                      tablet: (BuildContext context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildEditorPanel(),
                          const SizedBox(height: 20),
                          _buildSidebar(),
                        ],
                      ),
                      desktop: (BuildContext context) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _buildEditorPanel()),
                          const SizedBox(width: 24),
                          Expanded(flex: 3, child: _buildSidebar()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
