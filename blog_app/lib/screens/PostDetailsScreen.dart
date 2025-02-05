import 'package:blog_app/model/post_model.dart';
import 'package:blog_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/comment_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;

  PostDetailsScreen({super.key, required this.postId});

  @override
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final CommentController commentController = Get.put(CommentController());
    commentController.fetchComments(widget.postId); // Fetch comments on init
  }

  Future<String> _getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? ''; // Fetch current user ID
  }

  @override
  Widget build(BuildContext context) {
    final CommentController commentController = Get.put(CommentController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Post>(
        future: ApiService.getPostDetails(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Post not found'));
          } else {
            final post = snapshot.data!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.jumpTo(_scrollController
                  .position.maxScrollExtent); // Scroll to comments
            });
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      post.image != null && post.image!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "http://192.168.89.227:3000${post.image}",
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    'Image not available',
                                    style: TextStyle(color: Colors.red),
                                  );
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 16),
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 12),
                      const Text(
                        'Comments',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (commentController.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (commentController.comments.isEmpty) {
                          return const Text(
                              'No comments yet. Be the first to comment!');
                        } else {
                          return FutureBuilder<String>(
                            future: _getCurrentUserId(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (userSnapshot.hasError) {
                                return Text('Error: ${userSnapshot.error}');
                              } else if (userSnapshot.hasData) {
                                final currentUserId = userSnapshot.data!;
                                return Column(
                                  children:
                                      commentController.comments.map((comment) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      elevation: 5,
                                      child: ListTile(
                                        leading: GestureDetector(
                                          onTap: () {
                                            Get.to(() => UserProfileScreen(
                                                userId: comment.userId ==
                                                        currentUserId
                                                    ? currentUserId
                                                    : comment.userId));
                                          },
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                "http://192.168.89.227:3000${comment.userProfilePicture}"),
                                          ),
                                        ),
                                        title: GestureDetector(
                                          onTap: () {
                                            Get.to(() => UserProfileScreen(
                                                userId: comment.userId));
                                          },
                                          child: Text(comment.username),
                                        ),
                                        subtitle: Text(comment.content),
                                        trailing: currentUserId ==
                                                comment.userId
                                            ? IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () async {
                                                  bool confirmDelete =
                                                      await _showDeleteDialog();
                                                  if (confirmDelete) {
                                                    await _deleteComment(
                                                        comment.id,
                                                        commentController);
                                                  }
                                                },
                                              )
                                            : null,
                                      ),
                                    );
                                  }).toList(),
                                );
                              } else {
                                return const Text('User not found');
                              }
                            },
                          );
                        }
                      }),
                    ],
                  ),
                ),
                _buildCommentInputField(commentController),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCommentInputField(CommentController commentController) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController.commentController,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: () {
              if (commentController.commentController.text.isNotEmpty) {
                commentController.addComment(widget.postId);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(
      String commentId, CommentController commentController) async {
    try {
      bool isDeleted = await ApiService.deleteComment(commentId);
      if (isDeleted) {
        print("Comment deleted successfully in API");
        commentController.comments
            .removeWhere((comment) => comment.id == commentId);
        print("Comment removed from UI list");
        Get.snackbar('Success', 'Comment deleted successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        print("API deletion failed");
        Get.snackbar('Error', 'Failed to delete comment',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Error deleting comment: $e');
      Get.snackbar('Error', 'Failed to delete comment: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Comment'),
            content:
                const Text('Are you sure you want to delete this comment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
