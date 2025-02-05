import 'package:blog_app/controllers/PostController.dart';
import 'package:blog_app/services/api_service.dart';
import 'package:get/get.dart';

class NewPostController extends GetxController {
  final PostController postController = Get.find<PostController>();
  Future<void> addPost(String title, String content, String imagePath) async {
    try {
      final response = await ApiService().createPostWithImage(title, content, imagePath);

      if (response['success'] == true) {
        Get.snackbar('Success', 'Post created successfully!',
            snackPosition: SnackPosition.TOP);
            postController.fetchPosts();
            Get.offAllNamed('/home');
            
      } else {
        throw Exception(response['message'] ?? 'Failed to create post');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.TOP);
    }
  }
}
