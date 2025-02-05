import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServicess {
  static const String baseUrl = 'http://192.168.89.227:3000/api';

  // Method to fetch user profile
  // static Future<UserProfile> getUserProfile(String userId) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token') ?? ''; // Retrieve token from SharedPreferences
      
  //     final url = Uri.parse('$baseUrl/posts/user/$userId');
      
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token', // Add the token here
  //         'Content-Type': 'application/json', // Optional, but good practice
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return UserProfile.fromJson(data);
  //     } else {
  //       throw Exception('Failed to fetch user profile: ${response.statusCode} ${response.reasonPhrase}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching user profile: $e');
  //   }
  // }

  // // Method to update user profile
  // static Future<UserProfile> updateUserProfile(String userId, String username, {String? profilePicPath}) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token') ?? ''; // Retrieve token from SharedPreferences
      
  //     final url = Uri.parse('$baseUrl/user/$userId');
      
  //     // Prepare the body data
  //     Map<String, dynamic> body = {
  //       'username': username,
  //     };

  //     // If a profile picture path is provided, add it to the body
  //     if (profilePicPath != null) {
  //       body['profilePic'] = profilePicPath;
  //     }

  //     // Send the PUT request to update the profile
  //     final response = await http.put(
  //       url,
  //       body: json.encode(body),
  //       headers: {
  //         'Authorization': 'Bearer $token', // Add token for authentication
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return UserProfile.fromJson(data['user']);
  //     } else {
  //       throw Exception('Failed to update profile: ${response.statusCode} ${response.reasonPhrase}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error updating user profile: $e');
  //   }
  // }

  // Method to delete a post
  static Future<bool> deletePost(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? ''; 
      
      final url = Uri.parse('$baseUrl/posts/$postId'); 
      
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Add token for authentication
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true; // Successfully deleted
      } else {
        print('Failed to delete post: ${response.body}');
        throw Exception('Failed to delete post: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error while deleting post: $e');
      throw Exception('Failed to delete post');
    }
  }
}
