import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/notifications.dart' as model;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportnet/screens/authentication/login_page.dart';
import 'package:sportnet/models/models.dart';
import 'package:sportnet/screens/event_detail_page.dart';

class NotificationsPage extends StatefulWidget {
  final ValueChanged<int>? onUnreadCountChanged;
  final List<Event>? events;

  const NotificationsPage({super.key, this.onUnreadCountChanged, this.events});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Data notifikasi dipindahkan ke state agar bisa diubah (mutable)
  List<model.Notification> _notifications = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _refreshNotifications();
    });
  }

  Future<void> _fetchNotifications() async {
    try {
      // fetch data notifikasi dari server atau database
      final request = context.read<CookieRequest>();
      final response = await request.get(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/json/',
      );

      List<model.Notification> list = [];

      var data = response['notifications'] as List<dynamic>;
      for (var item in data) {
        if (item != null) {
          list.add(model.Notification.fromJson(item));
        }
      }
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
        _notifyUnreadCount();
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Event? _findEventById(String eventId) {
    if (widget.events == null) return null;
    try {
      return widget.events!.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }


  void _notifyUnreadCount() {
    widget.onUnreadCountChanged?.call(
      _notifications.where((n) => !n.isRead).length,
    );
  }

  void _refreshNotifications() async {
    if (!mounted) return;
    // Refresh di background tanpa loading indicator
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/json/',
      );

      List<model.Notification> list = [];
      var data = response['notifications'] as List<dynamic>;
      for (var item in data) {
        if (item != null) {
          list.add(model.Notification.fromJson(item));
        }
      }
      
      if (mounted) {
        setState(() {
          _notifications = list;
        });
        _notifyUnreadCount();
      }
    } catch (e) {
      print("Error refreshing notifications: $e");
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Fungsi untuk menandai semua sebagai sudah dibaca
  void _markAllAsRead() {
    final request = context.read<CookieRequest>();
    // Kirim request ke server untuk menandai semua sebagai sudah dibaca
    request.postJson(
      'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/api/read-all/',
      jsonEncode(<String, String>{}),
    );
    setState(() {
      _notifications = _notifications.map((n) {
        return model.Notification(
          id: n.id,
          title: n.title,
          message: n.message,
          timestamp: n.timestamp,
          isRead: true,
          eventId: n.eventId,
        );
      }).toList();
    });
    _notifyUnreadCount();
  }

  // Fungsi untuk menandai satu item sebagai sudah dibaca
  void _markAsRead(int index) async {
    final request = context.read<CookieRequest>();
    final notifId = _notifications[index].id;

    setState(() {
      final old = _notifications[index];
      _notifications[index] = model.Notification(
        title: old.title,
        message: old.message,
        timestamp: old.timestamp,
        isRead: true,
        eventId: old.eventId,
        id: old.id,
      );
    });
    _notifyUnreadCount();
    try {
      final response = await request.postJson(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/api/read/',
        jsonEncode(<String, String>{'notif_id': notifId.toString()}),
      );

      if (response['status'] != 'success') {
        print("Gagal mark read: ${response['message']}");
      }
    } catch (e) {
      print("Error koneksi: $e");
    }
  }

  // Fungsi untuk menghapus notifikasi
  void _deleteNotification(int index) async {
    final request = context.read<CookieRequest>();
    final notifId = _notifications[index].id;

    setState(() {
      _notifications.removeAt(index);
    });
    _notifyUnreadCount();
    try {
      final response = await request.postJson(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/api/delete/',
        jsonEncode(<String, String>{'notif_id': notifId.toString()}),
      );

      print("Delete Status: ${response['status']}");

      if (response['status'] != 'success') {
        // Handle jika gagal hapus di server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus: ${response['message']}")),
        );
      }
    } catch (e) {
      print("Error koneksi delete: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    const Color primaryOrange = Color(0xFFF0544F);
    if (!request.loggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifications")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tampilkan pesan error (opsional, bisa dipersingkat)
                Text(
                  "Please log in to view your notifications.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // --- Header dengan Tombol "Mark all as read" ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: _markAllAsRead,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- List ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationItem(
                            index,
                            _notifications[index],
                            primaryOrange,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    int index,
    model.Notification notif,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: !notif.isRead ? primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !notif.isRead
              ? primaryColor.withOpacity(0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: !notif.isRead
                      ? primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: !notif.isRead ? primaryColor : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              // Coba cari event dari widget.events terlebih dahulu
                              Event? event = _findEventById(notif.eventId);
                              
                              // Jika event ditemukan, navigasi ke detail page
                              if (event != null && mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetailPage(
                                      event: event!,
                                    ),
                                  ),
                                );
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Event tidak ditemukan'),
                                  ),
                                );
                              }
                            },
                            child:
                              Text(
                                notif.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: !notif.isRead
                                      ? const Color.fromARGB(255, 84, 138, 255)
                                      :   const Color.fromARGB(255, 120, 201, 255),
                                ),
                              ),
                          ),
                        ),
                        Text(
                          notif.timestamp.toLocal().toString().split(
                            ' ',
                          )[0], // Tampilkan hanya tanggal
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // --- Action Buttons Row ---
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!notif.isRead) ...[
                _buildActionButton(
                  icon: Icons.done_all,
                  label: 'Mark as read',
                  color: primaryColor,
                  onTap: () => _markAsRead(index),
                ),
                const SizedBox(width: 12),
              ],
              _buildActionButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: Colors.grey.shade600,
                onTap: () => _deleteNotification(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
