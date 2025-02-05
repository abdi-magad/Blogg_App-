import 'dart:io';
import 'package:blog_app/controllers/PostController.dart';
import 'package:blog_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String profilePic;
  final String bio;
  final PostController postController = Get.find();

  UpdateProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.profilePic,
    required this.bio,
  });

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _bio = '';
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _bio = widget.bio;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      try {
        String? imagePath;
        if (_profileImage != null) {
          imagePath = _profileImage!.path;
        }

        final response = await ApiService().updateUserProfile(
          widget.userId,
          _username,
          _bio,
          imagePath ?? widget.profilePic, // Use existing image if no new image selected
        );

        if (response != null) {
          Get.snackbar('Success', 'Profile updated successfully!', 
              snackPosition: SnackPosition.BOTTOM);
          widget.postController.fetchPosts();
          Navigator.pop(context, true); // Return to previous screen with refresh
        } else {
          Get.snackbar('Error', 'Failed to update profile', 
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to update profile: $e', 
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _getProfileImage(),
                    child: _showProfilePlaceholder(),
                  ),
                ),
                const SizedBox(height: 20),
                _buildUsernameField(),
                const SizedBox(height: 20),
                _buildBioField(),
                const SizedBox(height: 30),
                _buildUpdateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(File(_profileImage!.path));
    } else if (widget.profilePic.isNotEmpty) {
      return NetworkImage("http://192.168.89.227:3000${widget.profilePic}");
    }
    return null;
  }

  Widget? _showProfilePlaceholder() {
    if (_profileImage == null && widget.profilePic.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Colors.white);
    }
    return null;
  }

  Widget _buildUsernameField() {
    return TextFormField(
      initialValue: _username,
      decoration: const InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
      onChanged: (value) => setState(() => _username = value),
      validator: (value) => value?.isEmpty ?? true ? 'Please enter a username' : null,
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      initialValue: _bio,
      decoration: const InputDecoration(
        labelText: 'Bio',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.info_outline),
      ),
      maxLines: 3,
      onChanged: (value) => setState(() => _bio = value),
      validator: (value) => value?.isEmpty ?? true ? 'Please enter a bio' : null,
    );
  }

  Widget _buildUpdateButton() {
    return _isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Update Profile',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          );
  }
}