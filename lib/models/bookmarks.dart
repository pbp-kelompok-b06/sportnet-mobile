// lib/models/bookmarks.dart
import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class Bookmark {
  final String eventId;
  final String eventTitle;
  final String? eventDate;
  String note;

  Bookmark({
    required this.eventId,
    required this.eventTitle,
    this.eventDate,
    this.note = "",
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      eventId: json['event_id'] as String,
      eventTitle: json['event_name'] ?? '',
      eventDate: json['start_time'],
      note: json['note'] ?? '',
    );
  }
}

class BookmarkProvider extends ChangeNotifier {
  List<Bookmark> bookmarks = [];
  bool isLoading = false;
  String? errorMessage;

  static const String baseUrl = "http://localhost:8000";

  Future<void> loadBookmarks(CookieRequest request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await request.get(
        '$baseUrl/bookmark/api/bookmarks/',
      );

      final list = (response['bookmarks'] as List)
          .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
          .toList();

      bookmarks = list;
    } catch (e) {
      errorMessage = e.toString();
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
      final response = await request.postJson(
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
      await request.postJson(
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