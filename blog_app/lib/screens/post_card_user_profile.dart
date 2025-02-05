import 'package:blog_app/controllers/PostController.dart';
import 'package:blog_app/model/post_model.dart';
import 'package:blog_app/screens/PostDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PostCardUserProfile extends StatelessWidget {
  final Post post; // Use Post directly instead of Rx<Post>
  final Future<String> Function() getToken;

  const PostCardUserProfile({
    super.key,
    required this.post,
    required this.getToken,
  });

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final PostController postController = Get.find();
    final formattedDate = DateFormat.yMMMd().format(post.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => PostDetailsScreen(postId: post.id));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  if (post.image != null && post.image!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "http://192.168.89.227:3000${post.image}",
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Image not available',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Posted on: $formattedDate',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.hasLiked
                            ? Icons.thumb_up_alt_rounded
                            : Icons.thumb_up_off_alt_rounded,
                        size: 24,
                        color: post.hasLiked ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () async {
                        final String token = await getToken();
                        postController.updateLikes(
                          post.id,
                          post.hasLiked,
                          post.likes,
                          token,
                        );
                      },
                    ),
                    Text(
                      'Likes: ${post.likes}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(width: 15),
                    IconButton(
                      icon: const Icon(
                        Icons.comment_outlined,
                        size: 24,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Get.to(() => PostDetailsScreen(postId: post.id));
                      },
                    ),
                    Text(
                      'Comments: ${post.commentCount}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                FutureBuilder<String>(
                  future: getUserId(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(); // Show nothing while loading
                    }
                    if (snapshot.hasError) {
                      return const SizedBox(); // Handle errors if needed
                    }

                    final currentUserId = snapshot.data;
                    if (post.userId == currentUserId) {
                      return IconButton(
                        icon: const Icon(
                          Icons.delete_outlined,
                          size: 24,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Delete Post"),
                                content: const Text(
                                    "Are you sure you want to delete this post?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final String token = await getToken();
                                      await postController.deletePost(post.id);
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmDelete == true) {
                            // Get.snackbar('Success', 'Post deleted successfully',
                            //     snackPosition: SnackPosition.BOTTOM);
                          }
                        },
                      );
                    }
                    return const SizedBox(); // Return nothing if not the owner
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
