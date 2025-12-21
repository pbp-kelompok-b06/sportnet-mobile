import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportnet/models/models.dart';
import 'package:sportnet/screens/forum/forum_page.dart';
import 'package:sportnet/screens/review/review_page.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  static const Color _primaryOrange = Color(0xfffe4e11);

  String _formatFeeCompact(String raw) {
    final parsed = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
    if (parsed == null) return raw;
    // Contoh output: IDR 99K
    return NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    ).format(parsed);
  }

  String _formatDate(DateTime dt) {
    // "25 Nov 2025"
    return DateFormat('d MMM yyy', 'id_ID').format(dt);
  }

  String _formatTime(DateTime dt) {
    // "16:00\nWIB" (timezone WIB dipaksa biar match desain; kalau nanti kamu simpan timezone beneran, bisa diubah)
    return '${DateFormat('HH:mm', 'id_ID').format(dt)} WIB';
  }
  DateTime _toWib(DateTime dt) {
 
    if (dt.isUtc) return dt.add(const Duration(hours: 7));
    return dt.toUtc().add(const Duration(hours: 7));
  }

  String _formatTimeRangeWib(DateTime start, DateTime end) {
    final s = _toWib(start);
    final e = _toWib(end);
    final startStr = DateFormat('HH:mm').format(s);
    final endStr = DateFormat('HH:mm').format(e);
    return '$startStr - $endStr\nWIB';
  }

  String _shortLocation(String location, {int max = 10}) {
    if (location.length <= max) return location;
    return '${location.substring(0, max)}..';
  }

  String _proxyImageUrl(String thumbnail) {
    String url = thumbnail.trim();
    if (url.isEmpty) return '';

    if (!url.startsWith('http')) {
      url = 'https://anya-aleena-sportnet.pbp.cs.ui.ac.id$url';
    }

    return 'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(url)}';
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final headerUrl = _proxyImageUrl(widget.event.thumbnail);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Header image
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  flex: 42,
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Image.network(
                      headerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/image/no-image.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 58,
                  child: Container(color: Colors.white),
                ),
              ],
            ),
          ),

          // Back button (overlay)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: _CircleIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Bottom sheet content
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.30,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chips category
                    Row(
                      children: [
                        _ChipTag(text: e.sportsCategory.isEmpty ? 'Category' : e.sportsCategory),
                        const SizedBox(width: 8),
                        _ChipTag(text: e.activityCategory.isEmpty ? 'Category' : e.activityCategory),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Title + fee
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            e.name.isEmpty ? 'Event Name' : e.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatFeeCompact(e.fee),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 3 info cards
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            title: _formatDate(e.startTime),
                            // biar mirip desain yang 2 baris
                            centerText: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            title: _formatTimeRangeWib(e.startTime, e.endTime),
                            centerText: true,
                          ),

                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            location: e.location,
                            address: e.address,
                            centerText: true,
                          ),

                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      e.description.isEmpty ? 'Description.' : e.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Book + Bookmark row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: nanti hubungkan ke endpoint join / booking event
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Book Event tapped (belum dihubungkan ke backend).')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Book Event',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        _CircleIconButton(
                          icon: Icons.bookmark_border,
                          background: Colors.grey[200]!,
                          onTap: () {
                            // TODO: nanti bisa pakai BookmarkProvider.toggleBookmark
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bookmark tapped (belum dihubungkan).')),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Forum & Review cards
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            label: 'Forum',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForumPage(
                                    eventId: e.id,
                                    eventName: e.name,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ActionCard(
                            label: 'Review',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReviewPage(
                                    eventId: e.id,
                                    eventName: e.name,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipTag extends StatelessWidget {
  final String text;
  const _ChipTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF9E2E1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFB23B37),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String? title;
  final String? location;
  final String? address;
  final bool centerText;

  const _InfoCard({
    this.title,
    this.location,
    this.address,
    this.centerText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Align(
        alignment: centerText ? Alignment.center : Alignment.centerLeft,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // CASE 1: Card biasa (date / time)
    if (location == null || address == null) {
      return Text(
        title ?? '',
        textAlign: centerText ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      );
    }

    // CASE 2: Location card (location + address)
    return RichText(
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$location\n',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: address,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 86,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color background;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }
}
