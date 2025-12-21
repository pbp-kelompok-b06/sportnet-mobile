// lib/models/bookmarks.dart
import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportnet/models/models.dart';

class Bookmark {
  final String eventId;
  final Event event;
  String note;

  Bookmark({
    required this.eventId,
    required this.event,
    this.note = "",
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    final eventId = (json['event_id'] ?? '').toString();

    final event = Event(
      id: eventId,
      name: (json['event_name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(), // default "" kalau backend belum kirim
      thumbnail: (json['thumbnail'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      startTime: DateTime.tryParse((json['start_time'] ?? '').toString()) ?? DateTime(1970),
      endTime: DateTime.tryParse((json['end_time'] ?? '').toString()) ?? DateTime(1970),
      sportsCategory: (json['sports_category'] ?? '').toString(),
      activityCategory: (json['activity_category'] ?? '').toString(),
      fee: (json['fee'] ?? '0').toString(),
      capacity: int.tryParse((json['capacity'] ?? '0').toString()) ?? 0,
      organizer: (json['organizer'] ?? '').toString(),
    );

    return Bookmark(
      eventId: eventId,
      event: event,
      note: (json['note'] ?? '').toString(),
    );
  }
}

class BookmarkProvider extends ChangeNotifier {
  List<Bookmark> bookmarks = [];
  bool isLoading = false;
  String? errorMessage;

  static const String baseUrl = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id";

  Future<void> loadBookmarks(CookieRequest request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await request.get('$baseUrl/bookmark/api/bookmarks/');
      final raw = response['bookmarks'];
      if (raw is! List) {
        errorMessage = "Unexpected response: $response";
        bookmarks = [];
        return;
      }

      bookmarks = raw
          .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage = e.toString();
      bookmarks = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(
    CookieRequest request,
    String eventId, {
    String note = "",
  }) async {
    try {
      final response = await request.post(
        '$baseUrl/bookmark/api/bookmarks/toggle/$eventId/',
        {'note': note},
      );

      final status = response['status'];

      if (status == 'added') {
        await loadBookmarks(request);
      } else if (status == 'removed') {
        bookmarks.removeWhere((b) => b.eventId == eventId);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNote(
    CookieRequest request,
    String eventId,
    String note,
  ) async {
    try {
      await request.post(
        '$baseUrl/bookmark/api/bookmarks/note/$eventId/',
        {'note': note},
      );

      final idx = bookmarks.indexWhere((b) => b.eventId == eventId);
      if (idx != -1) {
        bookmarks[idx].note = note;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  bool isBookmarked(String eventId) {
    return bookmarks.any((b) => b.eventId == eventId);
  }
}