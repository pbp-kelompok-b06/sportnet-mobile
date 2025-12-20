class UserProfile {
  String id;
  String fullName;
  String username;
  String email;
  String role;
  String location;
  String about;
  String avatarUrl;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.role,
    required this.location,
    required this.about,
    required this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json["id"].toString(),
        fullName: json["full_name"] ?? "",
        username: json["username"] ?? "",
        email: json["email"] ?? "",
        role: json["role"] ?? "",
        location: json["location"] ?? "",
        about: json["about"] ?? "",
        avatarUrl: json["avatar_url"] ?? "",
      );
}

class Event {
  String id;
  String name;
  String description;
  String thumbnail;
  String location;
  String address;
  DateTime startTime;
  DateTime endTime;
  String sportsCategory;
  String activityCategory;
  String fee;
  int capacity;
  String organizer;

  // ✅ ALIAS biar kode lama yang pakai event.uuid tetap jalan
  String get uuid => id;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
    required this.location,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.sportsCategory,
    required this.activityCategory,
    required this.fee,
    required this.capacity,
    required this.organizer,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json["id"].toString(),
        name: json["name"] ?? "",
        description: json["description"] ?? "",
        thumbnail: json["thumbnail"] ?? "",
        location: json["location"] ?? "",
        address: json["address"] ?? "",
        startTime: DateTime.tryParse(json["start_time"] ?? "") ?? DateTime(1970),
        endTime: DateTime.tryParse(json["end_time"] ?? "") ?? DateTime(1970),
        sportsCategory: json["sports_category"] ?? "",
        activityCategory: json["activity_category"] ?? "",
        fee: json["fee"]?.toString() ?? "0",
        capacity: int.tryParse(json["capacity"]?.toString() ?? "0") ?? 0,
        organizer: json["organizer"] ?? "",
      );
}

class Bookmark {
  final String id;
  final String eventId;

  Bookmark({required this.id, required this.eventId});

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json["id"].toString(),
        eventId: json["event_id"].toString(),
      );
}

class ForumPost {
  final int id;
  final String username;
  final String content;
  final String createdAt;

  ForumPost({
    required this.id,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) => ForumPost(
        id: int.tryParse(json["id"].toString()) ?? 0,
        username: json["username"] ?? "",
        content: json["content"] ?? "",
        createdAt: json["created_at"] ?? "",
      );
}

class ReviewItem {
  final int id;
  final String username;
  final int rating;
  final String comment;
  final String createdAt;

  ReviewItem({
    required this.id,
    required this.username,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
        id: int.tryParse(json["id"].toString()) ?? 0,
        username: json["username"] ?? "",
        rating: int.tryParse(json["rating"].toString()) ?? 0,
        comment: json["comment"] ?? "",
        createdAt: json["created_at"] ?? "",
      );
}
