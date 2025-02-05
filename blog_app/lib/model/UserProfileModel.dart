import 'post_model.dart'; // Assuming Post is defined in a separate file

class UserProfile {
  final String username;
  final String email;
  final String profilePic;
  final String bio; // Added bio field
  final List<Post> posts;

  UserProfile({
    required this.username,
    required this.email,
    required this.profilePic,
    required this.bio, // Constructor updated
    required this.posts,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      email: json['email'],
      profilePic: json['profilePic'] ?? '',
      bio: json['bio'] ?? '', // Added bio mapping
      posts: List<Post>.from(json['posts'].map((post) => Post.fromJson(post))),
    );
  }
}

