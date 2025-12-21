import 'dart:convert';

Notification notificationFromJson(String str) => Notification.fromJson(json.decode(str));

String notificationToJson(Notification data) => json.encode(data.toJson());

class Notification {
    int id;
    String title;
    String message;
    bool isRead;
    DateTime timestamp;
    String eventId;

    Notification({
        required this.id,
        required this.title,
        required this.message,
        required this.isRead,
        required this.timestamp,
        required this.eventId,
    });

    factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        isRead: json["is_read"],
        timestamp: DateTime.parse(json["timestamp"]),
        eventId: json["event_id"]?? "",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "message": message,
        "is_read": isRead,
        "timestamp": timestamp.toIso8601String(),
        "event_id": eventId,
    };
}