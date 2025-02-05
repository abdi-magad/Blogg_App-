import 'package:blog_app/controllers/PostController.dart';
import 'package:blog_app/model/comment.dart';
import 'package:blog_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentController extends GetxController {
  var comments = <Comment>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  TextEditingController commentController = TextEditingController();

  // Fetch comments for a specific post
  Future<void> fetchComments(String postId) async {
    try {
      isLoading(true);
      errorMessage('');
      comments.clear();

      final fetchedComments = await ApiService.fetchComments(postId);
      comments.addAll(fetchedComments);
    } catch (e) {
      errorMessage('Failed to fetch comments: $e');
      print(errorMessage.value);
    } finally {
      isLoading(false);
    }
  }

  // Add a comment to a specific post
  Future<void> addComment(String postId) async {
    final content = commentController.text.trim();
    if (content.isEmpty) {
      Get.snackbar('Error', 'Comment cannot be empty');
      return;
    }

    try {
      isLoading(true);
      errorMessage('');
      await ApiService.addComment(postId, content);
      commentController.clear();

      // Fetch updated comment count after adding the comment
      await Get.find<PostController>().fetchCommentCount(postId);

      // Optionally fetch comments to refresh the list of comments if needed
      await fetchComments(postId);

      Get.snackbar('Success', 'Comment added successfully');
    } catch (e) {
      errorMessage('Failed to add comment: $e');
      Get.snackbar('Error', errorMessage.value);
      print(errorMessage.value);
    } finally {
      isLoading(false);
    }
  }

  // Delete a specific comment
  Future<void> deleteComment(String commentId) async {
    try {
      bool isDeleted = await ApiService.deleteComment(commentId);
      if (isDeleted) {
        comments.removeWhere((comment) => comment.id == commentId); // Remove from list
        Get.snackbar('Success', 'Comment deleted successfully',
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Failed to delete comment', 
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error deleting comment: $e');
      Get.snackbar('Error', 'Failed to delete comment: $e',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Check if the comment is owned by the current user
  Future<bool> isCommentOwner(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId') ?? '';
    final comment = comments.firstWhere((comment) => comment.id == commentId,
        orElse: () => Comment(
            id: '',
            content: '',
            username: '',
            userId: '',
            userProfilePicture: ''));
    return comment.userId == currentUserId;
  }
}
