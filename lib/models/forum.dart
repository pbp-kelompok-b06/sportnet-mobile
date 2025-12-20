class ForumPost {
  final int id;
  final String author;
  final String message;
  final DateTime createdAt;

  ForumPost({
    required this.id,
    required this.author,
    required this.message,
    required this.createdAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'],
      author: json['author'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
