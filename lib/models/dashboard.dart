// lib/models/dashboard.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportnet/models/models.dart';

class PinnedItem {
  final String pinId;
  final int position;
  final Event event;

  PinnedItem({
    required this.pinId,
    required this.position,
    required this.event,
  });

  factory PinnedItem.fromJson(Map<String, dynamic> json) {
    return PinnedItem(
      pinId: json["pin_id"].toString(),
      position: (json["position"] is int)
          ? json["position"]
          : int.tryParse(json["position"].toString()) ?? 1,
      event: Event.fromJson(json["event"] as Map<String, dynamic>),
    );
  }
}

class DashboardProvider extends ChangeNotifier {
  static const String baseUrl = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id";

  bool isLoading = false;
  String? errorMessage;

  List<Event> myEvents = [];
  List<PinnedItem> pins = [];
  int maxPinned = 3;

  Set<String> get pinnedIds => pins.map((p) => p.event.id).toSet();
  bool isPinned(String eventId) => pinnedIds.contains(eventId);

  Future<void> refreshAll(CookieRequest request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        fetchOrganizerEvents(request),
        fetchPins(request),
      ]);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrganizerEvents(CookieRequest request) async {
    final res = await request.get("$baseUrl/dashboard/api/organizer/events/");
    final raw = (res is Map) ? res["events"] : null;

    if (raw is! List) {
      throw Exception("Unexpected organizer events response: $res");
    }

    myEvents = raw
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> fetchPins(CookieRequest request) async {
    final res = await request.get("$baseUrl/dashboard/api/pins/");
    final rawPins = (res is Map) ? res["pins"] : null;

    if (rawPins is! List) {
      throw Exception("Unexpected pins response: $res");
    }

    maxPinned = (res["max_pinned"] is int)
        ? res["max_pinned"]
        : int.tryParse(res["max_pinned"]?.toString() ?? "") ?? 3;

    pins = rawPins
        .map((p) => PinnedItem.fromJson(p as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// return null kalau sukses; kalau gagal return message buat SnackBar/toast
  Future<String?> togglePin(CookieRequest request, String eventId) async {
    try {
      await request.postJson(
        "$baseUrl/dashboard/api/pins/toggle/$eventId/",
        jsonEncode({}),
      );

      await fetchPins(request);
      notifyListeners();
      return null;
    } catch (e) {
      final msg = e.toString().toLowerCase();

      if (msg.contains("409") || msg.contains("only pin") || msg.contains("you can only pin")) {
        return "You can only pin $maxPinned events";
      }

      return "Failed to toggle pin";
    }
  }

  /// direction: "left" / "right"
  Future<String?> movePin(
    CookieRequest request,
    String eventId,
    String direction,
  ) async {
    try {
      await request.postJson(
        "$baseUrl/dashboard/api/pins/move/$eventId/",
        jsonEncode({"direction": direction}),
      );

      await fetchPins(request);
      notifyListeners();
      return null;
    } catch (e) {
      return "Failed to move pin";
    }
  }
}