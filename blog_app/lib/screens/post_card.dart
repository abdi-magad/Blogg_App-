import 'package:blog_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/PostController.dart';
import 'PostDetailsScreen.dart';

class PostCard extends StatelessWidget {
  final post;
  final Future<String> Function() getToken;
  final String currentUserId; // Pass the logged-in user's ID

  const PostCard({
    super.key,
    required this.post,
    required this.getToken,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final PostController postController = Get.find();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      color: Theme.of(context).appBarTheme.backgroundColor, // Match AppBar color
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Row
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => UserProfileScreen(
                        userId: post.userId == currentUserId ? currentUserId : post.userId));
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        "http://192.168.89.227:3000${post.userProfilePicture}"),
                    radius: 22,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Get.to(() => UserProfileScreen(
                        userId: post.userId == currentUserId ? currentUserId : post.userId));
                  },
                  child: Text(
                    post.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (post.id == currentUserId)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // final String token = await getToken();
                      await postController.deletePost(post.id);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Post Title wrapped with GestureDetector
            GestureDetector(
              onTap: () {
                Get.to(() => PostDetailsScreen(postId: post.id));
              },
              child: Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18, // Slightly smaller font
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Post Content wrapped with GestureDetector
            GestureDetector(
              onTap: () {
                Get.to(() => PostDetailsScreen(postId: post.id));
              },
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),

            // Post Image with GestureDetector for click functionality
            if (post.image != null && post.image!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Navigate to the PostDetailsScreen when the image is tapped
                  Get.to(() => PostDetailsScreen(postId: post.id));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "http://192.168.89.227:3000${post.image}",
                    height: 200, // Adjust height for smaller card
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
              ),
            const SizedBox(height: 8),

            // Post Date
            Text(
              'Posted on: ${DateFormat.yMMMd().format(post.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),

            // Likes and Comments Row
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
                        size: 20, // Slightly smaller icon
                        color: post.hasLiked ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () async {
                        final String token = await getToken();
                        postController.updateLikes(
                            post.id, post.hasLiked, post.likes, token);
                      },
                    ),
                    Text(
                      '${post.likes} Likes',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.comment_outlined,
                        size: 20, // Slightly smaller icon
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Get.to(() => PostDetailsScreen(postId: post.id));
                      },
                    ),
                    Text(
                      '${post.commentCount} Comments',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

