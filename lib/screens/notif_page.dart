import 'package:flutter/material.dart';
import '../models/notifications.dart' as model;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Data notifikasi dipindahkan ke state agar bisa diubah (mutable)
  static List<model.Notification> _notifications = [
    model.Notification(
    id: 1,
    title: "Event Reminder",
    message: "Don't forget the Football Cup on Oct 25, 2024!",
    isRead: false,
    timestamp: DateTime.now(),
    eventId: "evt_001",
  ),   model.Notification(
    id: 2,
    title: "New Event Added",
    message: "Yoga Retreat has been added to your schedule.",
    isRead: false,
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    eventId: "evt_002",
  ),    model.Notification(
    id: 3,
    title: "Event Update",
    message: "The Badminton Fun event time has been changed.",
    isRead: false,
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    eventId: "evt_003",
  ),
  ]; 

  // Fungsi untuk menandai semua sebagai sudah dibaca
  void _markAllAsRead() {
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
  void _markAsRead(int index) {
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
  }

  // Fungsi untuk menghapus notifikasi
  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
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
            child: _notifications.isEmpty
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
                      return _buildNotificationItem(index, primaryOrange);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(int index, Color primaryColor) {
    final notif = _notifications[index];

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
                        Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: !notif.isRead
                                ? Colors.black
                                : Colors.grey.shade800,
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