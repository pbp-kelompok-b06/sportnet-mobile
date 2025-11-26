import 'package:flutter/material.dart';
import '../models/notifications.dart' as model; // Menggunakan alias untuk menghindari konflik nama

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Contoh data dummy menggunakan model.
  // Pastikan class di 'models/notifications.dart' bernama Notification
  // atau sesuaikan bagian ini dengan nama class Anda (misal: model.NotificationItem).
  static final List<model.Notification> _allNotifications = [
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

 @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF0544F);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Reduced slightly to accommodate button padding
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // --- List ---
            if (_allNotifications.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No notifications available.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _allNotifications.length,
                itemBuilder: (context, index) {
                  final notif = _allNotifications[index];
                  return _buildNotificationItem(notif, primaryOrange);
                },
              ),
            ),
          ],
        ),
      )
    ); 
  }

  Widget _buildNotificationItem(model.Notification notif, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: !notif.isRead ? primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !notif.isRead ? primaryColor.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: !notif.isRead ? primaryColor.withOpacity(0.1) : Colors.grey.shade100,
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
                        color: !notif.isRead ? Colors.black : Colors.grey.shade800,
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
    );
  }
}