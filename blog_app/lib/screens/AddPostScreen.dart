import 'dart:io';
import 'package:blog_app/controllers/new_post_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final NewPostController newPostController = Get.put(NewPostController());
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  XFile? _image;

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      }
    });
  }

  // Method to store the image locally
  Future<String> _storeImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageName = basename(imageFile.path);
    final imagePath = '${directory.path}/$imageName';
    await imageFile.copy(imagePath);
    return imagePath;
  }

  // Method to submit the post
  Future<void> _submitPost() async {
    final String title = titleController.text.trim();
    final String content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      Get.snackbar('Error', 'Title and content are required!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      String? imagePath;

      if (_image != null) {
        final imageFile = File(_image!.path);
        imagePath = await _storeImageLocally(imageFile); // Store the image locally
        print('Image stored at: $imagePath');
      }

      await newPostController.addPost(title, content, imagePath ?? '');

      // Clear fields and reset UI
      titleController.clear();
      contentController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      print('Error during post submission: $e');
      Get.snackbar('Error', 'Failed to create post: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // Custom Button Widget Inside AddPostScreen
  Widget customButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withOpacity(0.8), Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Custom Text Field Widget Inside AddPostScreen
  Widget customTextField(TextEditingController controller, String label, bool obscureText, IconData icon, {TextInputType inputType = TextInputType.text, int? maxLines}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitPost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              customTextField(titleController, 'Title', false, Icons.title),
              const SizedBox(height: 16),

              // Content Field
              customTextField(contentController, 'Content', false, Icons.edit, inputType: TextInputType.multiline, maxLines: 5),
              const SizedBox(height: 16),

              // Image Picker Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _image == null
                      ? const Center(child: Icon(Icons.add_a_photo, size: 50.0, color: Colors.grey))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_image!.path), fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              customButton('Submit Post', _submitPost),
            ],
          ),
        ),
      ),
    );
  }
}
