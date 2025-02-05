import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var isLoading = false.obs; // Add loading state

  // Method to handle user registration
  Future<void> register(String username, String email, String password) async {
    isLoading.value = true; // Set loading to true
    final response = await ApiService.registerUser(username, email, password);
    isLoading.value = false; // Set loading to false

    if (response.containsKey('error')) {
      Fluttertoast.showToast(
        msg: response['error'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      
    } else {
      Fluttertoast.showToast(
        msg: 'Registration successful!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      Get.offAllNamed('/login');
    }
  }

  // Method to handle user login
  Future<void> login(String email, String password) async {
    isLoading.value = true; // Set loading to true
    final response = await ApiService.loginUser(email, password);
    isLoading.value = false; // Set loading to false

    if (response.containsKey('error')) {
      Fluttertoast.showToast(
        msg: response['error'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      // Store the token
      await StorageService.saveToken(response['token']);
      isLoggedIn.value = true;
      Fluttertoast.showToast(
        msg: 'Login successful!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      Get.offAllNamed('/home'); // Navigate to Home screen
    }
  }

  // Method to logout
  Future<void> logout() async {
    await StorageService.clearToken();
    isLoggedIn.value = false;
    Get.offAllNamed('/login'); // Navigate to Login screen
  }
}
