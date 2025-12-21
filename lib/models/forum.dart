class ForumPost {
  final int id;
  final String author;
  final String message;
  final DateTime createdAt;
  final bool isOwner;

  ForumPost({
    required this.id,
    required this.author,
    required this.message,
    required this.createdAt,
    required this.isOwner,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'],
      author: json['username'],
      message: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isOwner: json['is_owner'] ?? false,
    );
  }
}
