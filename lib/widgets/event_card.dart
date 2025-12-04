import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportnet/models/models.dart';


class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({super.key, required this.event});

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  bool get _isFree {
    return event.fee.toLowerCase() == 'free' || event.fee == '0';
  }

  @override
  Widget build(BuildContext context) {
    String thumbnailUrl = event.thumbnail;

    if (!thumbnailUrl.startsWith('http')) {
      thumbnailUrl = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id$thumbnailUrl";
    }

    final String dateAndPlace = '${_formatDate(event.startTime)} - ${event.location}';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(event.thumbnail)}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade800,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                );
              },
            ),
           Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // stops mengontrol di mana warna berubah. 
                  // 0.3 artinya sampai 30% dari atas masih transparan.
                  stops: const [0.3, 1.0], 
                  colors: [
                    Colors.transparent, // Bagian atas transparan
                    const Color(0xFFFE4E11).withOpacity(0.9), // Bagian bawah orange kuat
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 5,
                    children: [
                      _buildPill(event.sportsCategory, const Color(0xFFFFE6D4), textColor: const Color(0xFF7E1B10)),
                      _buildPill(event.activityCategory, const Color(0xFFFFE6D4), textColor: const Color(0xFF7E1B10)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateAndPlace,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isFree)
                        _buildPill('Free', Colors.white.withOpacity(0.9), textColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text, Color backgroundColor, {Color textColor = Colors.white, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}