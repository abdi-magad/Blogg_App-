import 'package:blog_app/model/comment_count_model.dart';
import 'package:blog_app/model/post_model.dart';
import 'package:blog_app/services/api_service.dart';
import 'package:blog_app/services/userprofile.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostController extends GetxController {
  var isLoading = true.obs;
  var posts = <Post>[].obs; // For the Post's home screen
  var searchResults = <Post>[].obs; // For the search screen
  var errorMessage = ''.obs;
  var isLocked = false.obs; // Lock for concurrency control
  var userInfo = Rxn<Map<String, dynamic>>();
  var isFetched = false.obs;

  // Fetch posts and load like status
 Future<void> fetchPosts() async {
  try {
    isLoading(true);
    var fetchedPosts = await ApiService().getPosts();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    List<Post> processedPosts = fetchedPosts.map((postJson) {
      final likes = (postJson['likes'] as List?) ?? [];
      final hasLiked = likes.contains(userId);
      return Post.fromJson({...postJson, 'hasLiked': hasLiked});
    }).toList();

    posts.assignAll(processedPosts);
    searchResults.assignAll(processedPosts);
  } catch (e) {
    errorMessage.value = 'Failed to load posts: $e';
  } finally {
    isLoading(false);
  }
}

  Future<void> fetchAndUpdateLikeCount(String postId) async {
    try {
      final post = posts.firstWhere((post) => post.id == postId);
      int updatedCount = await ApiService().getLikeCountByPost(postId);
      post.likes = updatedCount;
      
    } catch (e) {
      errorMessage.value = 'Failed to fetch updated like count: $e';
    }
  }

  // Update Likes (both locally and in the backend)
  Future<void> updateLikes(String postId, bool currentHasLiked,
      int currentLikes, String token) async {
    if (isLocked.value) return;

    try {
      isLocked(true);
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return; // Post not found

      final post = posts[postIndex];
     
      final initialHasLiked = post.hasLiked;
      final initialLikes = post.likes;

      // Optimistic update
      post.hasLiked = !currentHasLiked;
      post.likes = post.hasLiked ? currentLikes + 1 : currentLikes - 1;

      // API Call
      final response = await ApiService().updateLikes(postId, token);

      if (response != null) {
        // Update from response if API succeeds
        post.likes = response['likes'] ?? post.likes;
        post.hasLiked = response['hasLiked'] ?? post.hasLiked;
      } else {
        // Rollback on API failure
        post.hasLiked = initialHasLiked;
        post.likes = initialLikes;
      }

      posts[postIndex] = post; // Update the specific post
    
      final searchPostIndex =
          searchResults.indexWhere((post) => post.id == postId);
      if (searchPostIndex != -1) {
        searchResults[searchPostIndex] =
            post; // Update directly without refresh
      }
    } catch (e) {
      // Rollback in case of an error
      print('Error during updateLikes: $e');
      errorMessage.value = 'Failed to update likes: $e';
    } finally {
      isLocked(false);
    }
  }

  // Fetch comment count for a post
  Future<void> fetchCommentCount(String postId) async {
    try {
      CommentCount commentCount = await ApiService().getCommentCount(postId);

      // Find the post and update the comment count
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        posts[postIndex].commentCount = commentCount.commentCount;
       
      }
    } catch (e) {
      errorMessage.value = 'Failed to load comment count: $e';
    }
  }

  // Delete Post
  Future<void> deletePost(String postId) async {
    try {
      bool isDeleted = await ApiServicess.deletePost(postId);
      if (isDeleted) {
        posts.removeWhere((post) => post.id == postId); // Remove from posts
        posts.refresh(); // refresh posts
        Get.snackbar('Success', 'Post deleted successfully',
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print('Error during deletePost: $e');
      Get.snackbar('Error', 'Failed to delete post: $e',
          snackPosition: SnackPosition.TOP);
    }
  }
  // update for user profile 
  Future<void> updateUserProfile(
      String name, String bio, String profilePicPath, String token) async {
    try {
      isLoading(true);

      final response = await ApiService()
          .updateUserProfile(name, bio, profilePicPath, token);

      if (response != null) {
        final updatedUser = Post.fromJson(response); 
        
        Get.snackbar('Profile Updated', 'Your profile has been updated',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage.value = 'Failed to update profile: $e';
    } finally {
      isLoading(false);
    }
  }

  void searchPosts(String query) {
    if (query.isEmpty) {
      searchResults.assignAll(posts); 
    } else {
      searchResults.assignAll(
        posts
            .where((post) =>
                post.title.toLowerCase().contains(query.toLowerCase()) ||
                post.content.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
   fetchPosts();
  }
}
