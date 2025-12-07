import 'package:flutter/material.dart';
import '../models/notifications.dart' as model;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Data notifikasi dipindahkan ke state agar bisa diubah (mutable)
  static List<model.Notification> _notifications = [];

  Future<List<model.Notification>> _fetchNotifications() async {
    // Simulasi pengambilan data notifikasi dari server atau database
    final request = context.read<CookieRequest>();
    print(request.loggedIn);
    final response = await request.get(
    'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/json/',
  );

  // Buat list sementara (lokal) agar tidak menumpuk data lama
    List<model.Notification> list = [];
    
    var data = response['notifications'] as List<dynamic>;
    for (var item in data) {
      if (item != null) {
        list.add(model.Notification.fromJson(item));
      }
    }
    _notifications = list; 
  
    return list;
  } 

  // Fungsi untuk menandai semua sebagai sudah dibaca
  void _markAllAsRead() {
    final request = context.read<CookieRequest>();
    // Kirim request ke server untuk menandai semua sebagai sudah dibaca
    request.postJson(
      'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/mark-read-all/',
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
  }

  // Fungsi untuk menandai satu item sebagai sudah dibaca
  void _markAsRead(int index) async {
    final request = context.read<CookieRequest>();
    final notifId = _notifications[index].id;
    
    // Optimistic UI Update: Ubah tampilan dulu biar cepat
    setState(() {
      final old = _notifications[index];
      _notifications[index] = model.Notification(
        title: old.title,
        message: old.message,
        timestamp: old.timestamp,
        isRead: true, // Ubah jadi true
        eventId: old.eventId,
        id: old.id,
      );
    });
    try {
      final response = await request.postJson(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/flutter-mark-as-read/',
        jsonEncode(<String, String>{
          'notif_id': notifId.toString(),
        }),
      );
      
      if (response['status'] != 'success') {
         // Jika gagal, kembalikan status (opsional) atau tampilkan snackbar
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

    // Simpan item sementara jika perlu undo (opsional)
    // final deletedItem = _notifications[index];

    setState(() {
      _notifications.removeAt(index);
    });

    try {
      final response = await request.postJson(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/delete-flutter/',
        jsonEncode(<String, String>{
          'notif_id': notifId.toString(),
        }),
      );

      print("Delete Status: ${response['status']}");
      
      if (response['status'] != 'success') {
         // Handle jika gagal hapus di server
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus: ${response['message']}"))
         );
      }
    } catch (e) {
      print("Error koneksi delete: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF0544F);
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
            child: FutureBuilder<List<model.Notification>>(
              future: _fetchNotifications(), // Panggil fungsi fetch
              builder: (context, snapshot) {
                // 1. Tampilkan Loading saat data sedang diambil
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } 
                
                // 2. Tampilkan Error jika gagal
                else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } 
                
                // 3. Tampilkan pesan jika data kosong
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No notifications',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                } 
                
                // 4. Tampilkan Data menggunakan ListView.builder
                else {
                  // Kita menggunakan _notifications yang sudah di-update di fetch
                  // atau bisa menggunakan snapshot.data!
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _notifications.length, // Jumlah item sesuai data
                    itemBuilder: (context, index) {
                      // Panggil widget item per notifikasi
                      return _buildNotificationItem(
                        index,
                        _notifications[index],
                        primaryOrange,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(int index, model.Notification notif, Color primaryColor) {

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

                        child: Text(
                          notif.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: !notif.isRead
                                ? Colors.black
                                : Colors.grey.shade800,
                          ),
                        ),
                        ),
                        Text(
                          notif.timestamp.toLocal().toString().split(' ')[0], // Tampilkan hanya tanggal
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

  IconData _getIconForType(String type) {
    switch (type) {
      case 'match':
        return Icons.calendar_today;
      case 'booking':
        return Icons.confirmation_number_outlined;
      case 'offer':
        return Icons.local_offer_outlined;
      case 'payment':
        return Icons.check_circle_outline;
      case 'friend':
        return Icons.group_add_outlined;
      default:
        return Icons.notifications_none;
    }
  }
}