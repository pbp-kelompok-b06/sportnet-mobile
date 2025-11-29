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
        id: json["id"],
        name: json["name"],
        description: json["description"],
        thumbnail: json["thumbnail"],
        location: json["location"],
        address: json["address"],
        startTime: DateTime.parse(json["start_time"]),
        endTime: DateTime.parse(json["end_time"]),
        sportsCategory: json["sports_category"],
        activityCategory: json["activity_category"],
        fee: json["fee"],
        capacity: json["capacity"],
        organizer: json["organizer"],
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
