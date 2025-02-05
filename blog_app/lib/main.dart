import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Check if the user is logged in by checking for a token
  Future<bool> _isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Get token from SharedPreferences
    return token != null && token.isNotEmpty; // Return true if token exists
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while checking login status
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          bool isLoggedIn = snapshot.data ?? false;
          return GetMaterialApp(
            title: 'Blog App',
            debugShowCheckedModeBanner: false,
            initialRoute: isLoggedIn ? '/home' : '/login', // Navigate based on login status
            getPages: [
              GetPage(name: '/login', page: () => LoginScreen()),
              GetPage(name: '/register', page: () => RegisterScreen()),
              GetPage(name: '/home', page: () => HomeScreen()),
            ],
          );
        }
      },
    );
  }
}
