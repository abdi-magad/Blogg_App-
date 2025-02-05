import 'package:blog_app/controllers/PostController.dart';
import 'package:blog_app/screens/search_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PostController postController = Get.put(PostController());

  @override
  void initState() {
    super.initState();
    postController.fetchPosts();

    // Add debounce mechanism in PostController to optimize search
    _searchController.addListener(() {
      postController.searchPosts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search posts...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              Future<String> getToken() async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                return prefs.getString('token') ?? '';
              }

              // State Management handled here
              if (postController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (postController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      postController.errorMessage.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (postController.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/no_results.json',
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No posts found. Try another search!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: postController.searchResults.length,
                  itemBuilder: (context, index) {
                    final post = postController.searchResults[index];
                    return Obx(() {
                      return SearchCard(
                        post: post,
                        getToken: getToken,
                        currentUserId:
                            postController.userInfo.value?['id'] ?? '',
                      );
                    });
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
