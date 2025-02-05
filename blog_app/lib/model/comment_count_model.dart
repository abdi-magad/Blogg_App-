class CommentCount {
  String id;
  String post;
  String user;
  String content;
  String createdAt;
  int commentCount;

  CommentCount({
    required this.id,
    required this.post,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.commentCount
  });

  factory CommentCount.fromJson(Map<String, dynamic> json) {
    return CommentCount(
      id: json['_id'] ?? '',
      post: json['post'] ?? '',
      user: json['user'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
       commentCount: json['commentCount'] ?? 0, 
    );
  }
}