import 'dart:convert';
import 'dart:io';
import 'package:blog_app/model/comment.dart';
import 'package:blog_app/model/comment_count_model.dart';
import 'package:blog_app/model/post_model.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = 'http://192.168.100.132:3000/api';
  static const String baseUrl = 'http://192.168.89.227:3000/api';
  // static const String baseUrl ='http://192.168.45.221:3000/api';

  // Method for registering a user
  static Future<Map<String, dynamic>> registerUser(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return json
            .decode(response.body); // Return the response body on success
      } else {
        return {'error': 'Registration failed. Please try again.'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  // Method for logging in a user
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final userId = data['_id'] ?? '';
        final token = data['token'] ?? '';
        final username = data['username'] ?? '';
        final bio = data['bio'] ?? '';
        final profilePic =
            data['profilePic'] ?? ''; // Assuming this field exists

        // Save the token, userId, and other user info in shared_preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', userId);
        await prefs.setString('username', username);
        await prefs.setString('bio', bio);
        await prefs.setString('profilePic', profilePic);

        return data; // Return the response body (includes token) on success
      } else {
        return {'error': 'Login failed. Check your credentials.'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  // Method for logging out a user
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove the token on logout
  }

  // Fetch posts
  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(decodedData);
      } else {
        throw Exception(
            'Failed to load posts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching posts: $e');
    }
  }

  // Function to create a post with an image
  Future<Map<String, dynamic>> createPostWithImage(
    String title,
    String content,
    String imagePath,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse('$baseUrl/posts');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = title
        ..fields['content'] = content;

      // Log information specific to post creation
      // print('--- Creating a new post ---');
      // print('Post Title: $title');
      // print('Post Content: $content');
      // print('Headers: ${request.headers}');
      if (imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        final image = http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(image);
        // print('Attaching image: ${imageFile.path}');
      } else {
        // print('No image attached.');
      }

      final response = await request.send();

      // print('Response Status Code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      // print('Response Body: $responseBody');

      if (response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception(
            'Failed to create post: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      // print('Error occurred while creating post: $e');
      throw Exception('An error occurred: $e');
    }
  }

// Function to update user profile
  Future<Map<String, dynamic>?> updateUserProfile(
      String userId, String name, String bio, String profilePicPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final uri = Uri.parse('$baseUrl/posts/$userId');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['username'] = name
        ..fields['bio'] = bio;

      if (profilePicPath.isNotEmpty) {
        final imageFile = File(profilePicPath);
        final imageBytes = await imageFile.readAsBytes();
        final image = http.MultipartFile.fromBytes(
          'profilePic',
          imageBytes,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(image);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception(
            'Failed to update profile: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('An error occurred while updating profile: $e');
    }
  }

  // Fetch post details by ID
  static Future<Post> getPostDetails(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Post.fromJson(data);
      } else {
        throw Exception('Failed to load post details');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Fetch the comment count for a specific post
  Future<CommentCount> getCommentCount(String postId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/comments/posts/$postId/comments/count'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the data
      return CommentCount.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load comment count');
    }
  }

  Future<bool> getUserLikeStatus(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/like-status'),
      headers: {'Authorization': 'Bearer YOUR_TOKEN'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['hasLiked'] ?? false;
    } else {
      throw Exception('Failed to fetch user like status');
    }
  }

  Future<int> getLikeCountByPost(String postId) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$postId/likes'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['likes'] ?? 0;
    } else {
      throw Exception('Failed to fetch like count');
    }
  }

  // Update Likes for a specific post
  Future<Map<String, dynamic>?> updateLikes(String postId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        // print('Response: $responseBody'); // Debugging

        return responseBody; // Ensure this contains the 'likes' field
      } else {
        throw Exception('Failed to update likes: ${response.body}');
      }
    } catch (e) {
      print('Error while updating likes: $e');
      return null;
    }
  }

  static Future<List<Comment>> getComments(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ??
          ''; // Retrieve token from SharedPreferences

      final url = Uri.parse('$baseUrl/posts/$postId/comments');
      final headers = {
        'Authorization': 'Bearer $token',
      };

      // Make the GET request to the API
      final response = await http.get(url, headers: headers);

      // print('Fetching comments from API: $url');
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the JSON response to a list of Comment objects
        List jsonData = json.decode(response.body);
        return jsonData.map((comment) => Comment.fromJson(comment)).toList();
      } else {
        // print(
        //     'Failed to load comments: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      // print('Error during fetchComments: $e');
      throw Exception('An error occurred while fetching comments');
    }
  }

  // Fetch comments for a specific post
  // Fetch comments for a specific post
  static Future<List<Comment>> fetchComments(String postId) async {
    final url = Uri.parse('$baseUrl/comments/posts/$postId/comments');
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('token') ?? ''; // Retrieve token from SharedPreferences

    // print('Fetching comments for postId=$postId');

    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse the JSON response to a list of Comment objects
        List jsonData = json.decode(response.body);
        return jsonData.map((comment) => Comment.fromJson(comment)).toList();
      } else {
        // print(
        //     'Failed to fetch comments: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      // print('Error fetching comments: $e');
      throw Exception('An error occurred while fetching comments');
    }
  }

// Add a new comment to a post
  static Future<void> addComment(String postId, String commentContent) async {
    final url = Uri.parse(
        '$baseUrl/comments/posts/$postId/comments'); // Corrected endpoint
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('token') ?? ''; // Retrieve token from SharedPreferences

    if (token.isEmpty) {
      // print('Error: No authentication token found.');
      throw Exception('User is not authenticated');
    }

    // print('Adding comment: postId=$postId, content=$commentContent');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode({
      'content': commentContent.trim(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        // print('Comment added successfully: ${response.body}');
      } else if (response.statusCode == 400) {
        // print('Validation error: ${response.body}');
        throw Exception('Invalid comment content');
      } else if (response.statusCode == 404) {
        // print('Post not found: ${response.body}');
        throw Exception('Post does not exist');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // print('Authentication error: ${response.body}');
        throw Exception('User is not authorized');
      } else {
        // print('Failed to add comment: ${response.body}');
        throw Exception('Failed to add comment. Please try again later.');
      }
    } catch (e) {
      // print('Error adding comment: $e');
      throw Exception(
          'An error occurred while adding the comment. Please check your internet connection or try again later.');
    }
  }

// Delete a specific comment
  static Future<bool> deleteComment(String commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('$baseUrl/comments/$commentId'); // Corrected typo
      final headers = {'Authorization': 'Bearer $token'};

      print("Sending DELETE request to: $url");

      final response = await http.delete(url, headers: headers);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Comment deleted successfully");
        return true;
      } else {
        print("Failed to delete comment. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('Error during deleteComment: $e');
      return false;
    }
  }

  // Fetch posts by a specific user
  // Future<List<Map<String, dynamic>>> getPostsByUser(String userId) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token') ?? '';

  //     final response = await http.get(
  //       Uri.parse('$baseUrl/posts/user/$userId'), // Adjust endpoint accordingly
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> decodedData = json.decode(response.body);
  //       return List<Map<String, dynamic>>.from(decodedData);
  //     } else {
  //       throw Exception(
  //           'Failed to load user posts: ${response.statusCode} - ${response.body}');
  //     }
  //   } catch (e) {
  //     throw Exception('An error occurred while fetching user posts: $e');
  //   }
  // }

  static Future<Map<String, dynamic>> getUserInfo(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/posts/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch user info');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  static Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // Search posts by query
  static Future<List<dynamic>> searchPosts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/search?keyword=$query'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> posts = json.decode(response.body);
        return posts;
      } else {
        throw Exception("Failed to search posts: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error searching posts: $e");
    }
  }
}
