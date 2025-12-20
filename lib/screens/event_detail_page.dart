import 'package:flutter/material.dart';
import 'package:sportnet/screens/forum/forum_page.dart';
import 'package:sportnet/screens/review/review_page.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;
  final String eventName;

  const EventDetailPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              eventName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ForumPage(
                      eventId: eventId,
                      eventName: eventName,
                    ),
                  ),
                );
              },
              child: const Text("Open Forum"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewPage(
                      eventId: eventId,
                      eventName: eventName,
                    ),
                  ),
                );
              },
              child: const Text("Open Review"),
            ),
          ],
        ),
      ),
    );
  }
}
