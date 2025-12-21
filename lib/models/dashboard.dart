// lib/models/dashboard.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportnet/models/models.dart';

class PinnedItem {
  final String pinId;
  int position;
  final Event event;

  PinnedItem({
    required this.pinId,
    required this.position,
    required this.event,
  });

  factory PinnedItem.fromJson(Map<String, dynamic> json) {
    final ev = (json['event'] as Map?)?.cast<String, dynamic>() ?? {};
    return PinnedItem(
      pinId: (json['pin_id'] ?? '').toString(),
      position: (json['position'] ?? 1) as int,
      event: Event.fromJson(_normalizeEventJson(ev)),
    );
  }
}

Map<String, dynamic> _normalizeEventJson(Map<String, dynamic> raw) {
  return {
    "id": (raw["id"] ?? "").toString(),
    "name": raw["name"] ?? "",
    "thumbnail": raw["thumbnail"],
    "start_time": raw["start_time"],
    "end_time": raw["end_time"],
    "location": raw["location"] ?? "",
    "address": raw["address"] ?? "",
    "sports_category": raw["sports_category"] ?? "",
    "activity_category": raw["activity_category"] ?? "",
    "fee": raw["fee"],
    "capacity": raw["capacity"] ?? 0,
    "attendee_count": raw["attendee_count"] ?? 0,
  };
}

// PROVIDER
class DashboardProvider extends ChangeNotifier {
  static const String _base = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id";

  bool isLoading = true;
  String? errorMessage;

  int maxPinned = 3;
  List<PinnedItem> pins = [];
  List<Event> myEvents = [];

  final Set<String> _pinnedIds = {};

  bool isPinned(String eventId) => _pinnedIds.contains(eventId);

  int get totalEvents => myEvents.length;

  int get totalAttendees =>
      myEvents.fold(0, (sum, e) => sum + e.attendeesCount);

  Future<void> refreshAll(CookieRequest request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _fetchPins(request),
        _fetchMyEvents(request),
      ]);

      // rebuild pinnedIds
      _pinnedIds
        ..clear()
        ..addAll(pins.map((p) => p.event.id.toString()));

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _fetchPins(CookieRequest request) async {
    final res = await request.get("$_base/dashboard/api/pins/");
    final map = (res is Map) ? res.cast<String, dynamic>() : <String, dynamic>{};

    maxPinned = (map["max_pinned"] ?? 3) as int;

    final list = (map["pins"] is List) ? (map["pins"] as List) : <dynamic>[];
    pins = list
        .whereType<Map>()
        .map((x) => PinnedItem.fromJson(x.cast<String, dynamic>()))
        .toList();

    pins.sort((a, b) => a.position.compareTo(b.position));
  }

  Future<void> _fetchMyEvents(CookieRequest request) async {
    final res = await request.get("$_base/dashboard/get-organizer-events-json/");
    final map = (res is Map) ? res.cast<String, dynamic>() : <String, dynamic>{};
    final list = (map["events"] is List) ? (map["events"] as List) : <dynamic>[];

    myEvents = list.whereType<Map>().map((x) {
      final m = x.cast<String, dynamic>();

      final normalized = _normalizeEventJson({
        "id": m["id"],
        "name": m["name"],
        "thumbnail": m["thumbnail"],
        "start_time": m["start_time"], 
        "end_time": m["end_time"],
        "location": m["location"],
        "address": m["address"],
        "sports_category": m["sports_category"],
        "activity_category": m["activity_category"],
        "fee": m["fee"],
        "capacity": m["capacity"],
        "attendee_count": m["attendee_count"],
      });

      return Event.fromJson(normalized);
    }).toList();
  }

  Future<String?> togglePin(CookieRequest request, String eventId) async {
    try {
      final res = await request.postJson(
        "$_base/dashboard/api/pins/toggle/$eventId/",
        jsonEncode({}),
      );

      if (res is Map) {
        final status = (res["status"] ?? "").toString();
        if (status == "error" || res["detail"] != null) {
          return (res["detail"] ?? "Failed to toggle pin.").toString();
        }
      }

      await refreshAll(request);
      return null;
    } catch (e) {
      final msg = e.toString();
      if (msg.toLowerCase().contains("409") ||
          msg.toLowerCase().contains("only pin") ||
          msg.toLowerCase().contains("pin 3")) {
        return "You can only pin 3 events";
      }
      return "Failed to toggle pin";
    }
  }

  Future<String?> movePin(CookieRequest request, String eventId, String direction) async {
    try {
      final res = await request.postJson(
        "$_base/dashboard/api/pins/move/$eventId/",
        jsonEncode({"direction": direction}),
      );

      if (res is Map && (res["status"] ?? "") == "noop") {
        return null;
      }

      await refreshAll(request);
      return null;
    } catch (e) {
      return "Failed to move pin";
    }
  }

  PinnedItem? _findPin(String eventId) {
    try {
      return pins.firstWhere((p) => p.event.id == eventId);
    } catch (_) {
      return null;
    }
  }

  Future<String?> movePinToPosition(
    CookieRequest req,
    String eventId,
    int targetPosition,
  ) async {
    final pin = _findPin(eventId);
    if (pin == null) return "Pin not found";

    targetPosition = targetPosition.clamp(1, pins.length);

    while (pin.position < targetPosition) {
      final msg = await movePin(req, eventId, "right");
      if (msg != null) return msg;
      final updated = _findPin(eventId);
      if (updated == null) break;
      pin.position = updated.position;
    }

    while (pin.position > targetPosition) {
      final msg = await movePin(req, eventId, "left");
      if (msg != null) return msg;
      final updated = _findPin(eventId);
      if (updated == null) break;
      pin.position = updated.position;
    }

    return null;
  }
}