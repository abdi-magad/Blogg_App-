class Post {
  String id;
  String title;
  String content;
  String userId;
  String userProfilePicture;
  String username;
  String email;
  String bio;
  String? image;
  bool hasLiked;
  int likes;
  int commentCount;
  DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.userProfilePicture,
    required this.username,
    required this.email,
    required this.bio,
    this.image,
    this.hasLiked = false,
    this.likes = 0,
    this.commentCount = 0,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
  return Post(
    id: json['_id'] ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    userId: json['userId'] ?? '',
    userProfilePicture: json['userProfilePicture'] ?? '',
    username: json['username'] ?? '',
    email: json['email'] ?? '', 
    bio: json['userBio'] ?? '',
    image: json['image'] ?? null,
    hasLiked: json['hasLiked'] ?? false,
    likes: (json['likes'] is List) ? json['likes'].length : 0,
    commentCount: (json['comments'] is List) ? json['comments'].length : 0, 
    createdAt: json.containsKey('createdAt')
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}
}
