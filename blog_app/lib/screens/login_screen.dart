import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: emailController,
              label: 'Email',
              obscureText: false,
              icon: Icons.email,
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: passwordController,
              label: 'Password',
              obscureText: true,
              icon: Icons.lock,
            ),
            SizedBox(height: 30),
            Obx(
              () => authController.isLoading.value
                  ? CircularProgressIndicator()
                  : CustomButton(
                      label: 'Login',
                      onPressed: () async {
                        await authController.login(
                          emailController.text,
                          passwordController.text,
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => Get.toNamed('/register'),
              child: Text(
                'Don\'t have an account? Register here',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
