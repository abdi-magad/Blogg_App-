class Comment {
   final String id;
  final String userId; 
  final String username;
  final String userProfilePicture;
  final String content;

  Comment({
     required this.id,
    required this.userId, 
    required this.username,
    required this.userProfilePicture,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
       id: json['_id'],
      userId: json['user']['_id'] ?? '', 
      username: json['user']['username'] ?? 'Anonymous', 
      userProfilePicture: json['user']['profilePic'] ?? '', 
      content: json['content'] ?? '',
    );
  }
}
