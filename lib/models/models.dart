// To parse this JSON data, do
//
//     final event = eventFromJson(jsonString);

import 'dart:convert';

Event eventFromJson(String str) => Event.fromJson(json.decode(str));

String eventToJson(Event data) => json.encode(data.toJson());

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
        id: json["id"]?.toString() ?? "",
        name: json["name"] ?? "Unknown Event",
        description: json["description"] ?? "No description available",
        thumbnail: json["thumbnail"] ?? "",
        location: json["location"] ?? "Unknown Location",
        address: json["address"] ?? "",
        
        // Cek null sebelum parse tanggal, gunakan DateTime.now() sebagai fallback
        startTime: json["start_time"] != null 
            ? DateTime.parse(json["start_time"]) 
            : DateTime.now(),
        endTime: json["end_time"] != null 
            ? DateTime.parse(json["end_time"]) 
            : DateTime.now(),
            
        sportsCategory: json["sports_category"] ?? "General",
        activityCategory: json["activity_category"] ?? "Event",
        
        // Logika fee tetap sama, tapi tambahkan toString() aman
        fee: json["fee"] == 0 || json["fee"] == null ? 'free' : json["fee"].toString(),
        
        capacity: json["capacity"] ?? 0,
        organizer: json["organizer"] ?? "Unknown Organizer",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "thumbnail": thumbnail,
        "location": location,
        "address": address,
        "start_time": startTime.toIso8601String(),
        "end_time": endTime.toIso8601String(),
        "sports_category": sportsCategory,
        "activity_category": activityCategory,
        "fee": fee,
        "capacity": capacity,
        "organizer": organizer,
    };
}
