import 'package:blog_app/controllers/PostController.dart';
import 'package:blog_app/model/post_model.dart';
import 'package:blog_app/screens/AddPostScreen.dart';
import 'package:blog_app/screens/login_screen.dart';
import 'package:blog_app/screens/post_card_user_profile.dart';
import 'package:blog_app/screens/update_user_profile.dart';
import 'package:blog_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserProfileScreen extends StatelessWidget {
  final String userId;
  final PostController postController = Get.put(PostController());
  UserProfileScreen({super.key, required this.userId});

  Future<String> _getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Redirect to login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 170, 225, 255),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        endDrawer: FutureBuilder<String>(
          future: _getCurrentUserId(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == userId) {
              print("User Info: ${snapshot.data}");
              return Drawer(
                elevation: 10,
                child: Material(
                  color: Colors.white,
                  child: SafeArea(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const DrawerHeader(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 170, 225, 255),
                          ),
                          child: Text(
                            'Profile Options',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.blue),
                          title: const Text('Edit Profile'),
                          onTap: () async {
                            // Fetch user data before navigating
                            final userData = await ApiService.getUserInfo(userId);
                            if (userData != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateProfileScreen(
                                    userId: userId,
                                    username: userData['username'] ?? '',
                                    bio: userData['bio'] ?? '',
                                    profilePic: userData['profilePic'] ?? '',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to fetch user data')),
                              );
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.exit_to_app, color: Colors.red),
                          title: const Text('Logout'),
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink(); // If user ID doesn't match, no drawer is shown
          },
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: ApiService.getUserInfo(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            if (snapshot.hasData) {
              final user = snapshot.data!;

              return Obx(() {
                if (!postController.isFetched.value) {
                  // Defer fetching posts until after the first build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    postController.fetchPosts();
                    postController.isFetched.value = true;
                  });
                }

                final userPosts = postController.posts
                    .where((post) => post.userId == userId)
                    .toList();

                final likedPosts = postController.posts
                    .where((post) => post.hasLiked)
                    .toList();

                return Column(
                  children: [
                    _buildProfileHeader(context, user, userPosts.length),
                    const TabBarSection(),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildUserPostsTab(context, userPosts),
                          _buildLikedPostsTab(context, likedPosts),
                        ],
                      ),
                    ),
                  ],
                );
              });
            } else {
              return const Center(child: Text('No user data available.'));
            }
          },
        ),
        floatingActionButton: FutureBuilder<String>(
          future: _getCurrentUserId(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == userId) {
              return FloatingActionButton(
                onPressed: () {
                  // Navigate to the AddPostScreen when the FAB is pressed
                  Get.to(() => AddPostScreen());
                },
                backgroundColor: Colors.blue, // FAB color
                child: const Icon(Icons.add),
              );
            }
            return SizedBox.shrink(); // Hide FAB if user ID doesn't match
          },
        ),
      ),
    );
  }

  // Profile Header
  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> user, int totalPosts) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 100, 159, 184), const Color.fromARGB(255, 138, 238, 255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: user['profilePic'] != null
                ? NetworkImage("http://192.168.89.227:3000${user['profilePic']}")
                : null,
            child: user['profilePic'] == null
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            user['username'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user['email'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              user['bio'] ?? 'No bio available',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('Posts', totalPosts),
              const SizedBox(width: 24),
              _buildStatItem('Likes', postController.posts
                  .where((post) => post.hasLiked)
                  .length),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for stats
  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // User Posts Tab
  Widget _buildUserPostsTab(BuildContext context, List<Post> userPosts) {
    Future<String> getToken() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token') ?? '';  // Provide a default empty string if token is null
    }

    if (userPosts.isEmpty) {
      return const Center(child: Text("This user hasn't created any posts yet.", style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return PostCardUserProfile(post: post, getToken: getToken);
      },
    );
  }

  // Liked Posts Tab
  Widget _buildLikedPostsTab(BuildContext context, List<Post> likedPosts) {
    Future<String> getToken() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token') ?? '';  // Provide a default empty string if token is null
    }

    if (likedPosts.isEmpty) {
      return const Center(child: Text("No liked posts available.", style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      itemCount: likedPosts.length,
      itemBuilder: (context, index) {
        final post = likedPosts[index];
        return PostCardUserProfile(post: post, getToken: getToken);
      },
    );
  }
}

class TabBarSection extends StatelessWidget {
  const TabBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: Colors.black,
      indicatorColor: Colors.blue,
      tabs: [
        Tab(
          icon: Icon(Icons.article), // Icon for "My Posts"
          text: 'My Posts',
        ),
        Tab(
          icon: Icon(Icons.favorite), // Icon for "Liked Posts"
          text: 'Liked Posts',
        ),
      ],
    );
  }
}