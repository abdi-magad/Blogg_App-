import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/PostController.dart';
import 'PostDetailsScreen.dart';

class SearchCard extends StatelessWidget {
  final post;
  final Future<String> Function() getToken;
  final String currentUserId; // Pass the logged-in user's ID

  const SearchCard({
    super.key,
    required this.post,
    required this.getToken,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final PostController postController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Get.to(() => PostDetailsScreen(postId: post.id));
          },
          child: Card(
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
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage("http://192.168.89.227:3000${post.userProfilePicture}"),
                        radius: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          post.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (post.id == currentUserId) // Check post ownership
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final String token = await getToken();
                            await postController.deletePost(post.id);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
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
                    'Posted on: ${DateFormat.yMMMd().format(post.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Add likes and comments row
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
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
                        postController.updateLikes(post.id, post.hasLiked, post.likes, token);
                      },
                    ),
                    Text(
                      'Likes: ${post.likes}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                Row(
                  children: [
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
                      '${post.commentCount} comments',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
