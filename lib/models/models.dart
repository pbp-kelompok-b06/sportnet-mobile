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
  String organizerName;     
  String organizerPicture;  
  int attendeesCount;       
  List<String> attendeeImages; 
  bool isJoined;            

  String get uuid => id;
  int get pk => int.tryParse(id) ?? 0;
  String get organizerUsername => organizer; 

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

    this.organizerName = "",
    this.organizerPicture = "",
    this.attendeesCount = 0,
    this.attendeeImages = const [],
    this.isJoined = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String orgUsername = "";
    String orgName = "Organizer";
    String orgPic = "";

    if (json["organizer"] != null) {
      if (json["organizer"] is Map) {
        orgUsername = json["organizer"]["username"] ?? "";
        orgName = json["organizer"]["full_name"] ?? "";
        orgPic = json["organizer"]["profile_picture"] ?? "";
      } else {
        orgUsername = json["organizer"].toString();
        orgName = json["organizer"].toString(); 
      }
    }
    int attCount = 0;
    List<String> attAvatars = [];
    
    if (json['attendees'] != null && json['attendees'] is Map) {
      attCount = json['attendees']['count'] ?? 0;
      if (json['attendees']['avatars'] != null) {
        attAvatars = List<String>.from(json['attendees']['avatars']);
      }
    } else {
      attCount = int.tryParse(json["attendees_count"]?.toString() ?? "0") ?? 0;
    }

    return Event(
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

      organizer: orgUsername, 
      organizerName: orgName,
      organizerPicture: orgPic,
      attendeesCount: attCount,
      attendeeImages: attAvatars,
      isJoined: json["is_joined"] ?? false,
    );
  }
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
