import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: usernameController,
              label: 'Username',
              obscureText: false,
              icon: Icons.person,
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
                      label: 'Register',
                      onPressed: () async {
                        await authController.register(
                          usernameController.text,
                          emailController.text,
                          passwordController.text,
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => Get.toNamed('/login'), // Navigate to Login screen
              child: Text(
                'Already have an account? Login here',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
