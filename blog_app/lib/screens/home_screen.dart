import 'package:blog_app/controllers/PostController.dart';
import 'package:blog_app/screens/SearchScreen%20.dart';
import 'package:blog_app/screens/post_card.dart';
import 'package:blog_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostController postController = Get.put(PostController());
  int _selectedIndex = 0;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? "";
    });
  }

  // List of screens for BottomNavigationBar
  final List<Widget> _screens = [
    HomeScreenContent(userId: '',),
    SearchScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), 
        child: AppBar(
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Blog App",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 4,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Color.fromARGB(255, 176, 176, 39)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            FutureBuilder<Map<String, dynamic>>(
              future: ApiService.getUserInfo(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.error, color: Colors.white),
                    ),
                  );
                } else {
                  final user = snapshot.data!;
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => UserProfileScreen(userId: userId));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: user['profilePic'] != null
                            ? NetworkImage(
                                "http://192.168.89.227:3000${user['profilePic']}")
                            : null,
                        child: user['profilePic'] == null
                            ? const Icon(Icons.person,
                                size: 30, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE5E5E5), Color(0xFFF5F5F5)], // Light background gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final PostController postController = Get.put(PostController());
  final String userId;

  HomeScreenContent({super.key, required this.userId});

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  @override
Widget build(BuildContext context) {
  return Obx(() {
    if (postController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    } else if (postController.errorMessage.value.isNotEmpty) {
      return Center(child: Text(postController.errorMessage.value));
    } else if (postController.posts.isEmpty) {
      return const Center(child: Text("No posts available."));
    } else {
      return ListView.builder(
        itemCount: postController.posts.length,
        itemBuilder: (context, index) {
          final post = postController.posts[index];
          return PostCard(
            post: post,
            getToken: getToken,
            currentUserId: userId,
          );
        },
      );
    }
  });
}
}
