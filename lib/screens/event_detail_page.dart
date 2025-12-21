import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/models/models.dart';
import 'package:sportnet/screens/authentication/login_page.dart';
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
  static const Color _primaryOrange = Color(0xFFF0544F);
  static const String _baseUrl = 'https://anya-aleena-sportnet.pbp.cs.ui.ac.id';

  bool _isBooking = false;
  

  DateTime _toWib(DateTime dt) {
    if (dt.isUtc) return dt.add(const Duration(hours: 7));
    return dt.toUtc().add(const Duration(hours: 7));
  }

  String _formatFeeCompact(String raw) {
    final parsed = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
    if (parsed == null) return raw;
    return NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    ).format(parsed);
  }

  String _formatDate(DateTime dt) {
    final wib = _toWib(dt);
    return DateFormat('d MMM yyyy', 'id_ID').format(wib);
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final s = _toWib(start);
    final e = _toWib(end);
    final startStr = DateFormat('HH:mm', 'id_ID').format(s);
    final endStr = DateFormat('HH:mm', 'id_ID').format(e);
    return '$startStr - $endStr\nWIB';
  }

  String _proxyImageUrl(String thumbnail) {
    String url = thumbnail.trim();
    if (url.isEmpty) return '';

    if (!url.startsWith('http')) {
      url = '$_baseUrl$url';
    }

    return '$_baseUrl/proxy-image/?url=${Uri.encodeComponent(url)}';
  }

  String _timeTextForDialog(Event e) {
    final startWib = _toWib(e.startTime);
    final endWib = _toWib(e.endTime);

    final startDate = DateFormat('EEEE, d MMM yyyy', 'en_US').format(startWib);
    final startTime = DateFormat('HH:mm', 'en_US').format(startWib);
    final endDateTime = DateFormat('d MMM yyyy, HH:mm', 'en_US').format(endWib);
    return '$startDate • $startTime - $endDateTime WIB';
  }

  Future<bool?> _showJoinConfirmationDialog() {
    final e = widget.event;

    final feeText =
        (e.fee.toLowerCase() == 'free' || e.fee == '0') ? 'Free' : _formatFeeCompact(e.fee);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Join this event?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFF7F50),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Event: ${e.name}\n'
                  'Location: ${e.location}\n'
                  'Time: ${_timeTextForDialog(e)}\n'
                  'Fee: $feeText',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6E8EC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _joinEvent(CookieRequest request) async {
    if (_isBooking) return;
    setState(() => _isBooking = true);

    try {
      final url = '$_baseUrl/event/api/${widget.event.id}/join/'; 
      final response = await request.post(url, {});

      final status = (response is Map && response['status'] != null)
          ? response['status'].toString().toLowerCase()
          : null;

      final message = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : null;

      if (!mounted) return;

      if (status == 'success' || status == 'ok' || status == 'joined') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Berhasil join event!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Gagal join event. Coba lagi.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat join event: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final headerUrl = _proxyImageUrl(widget.event.thumbnail);
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                    Row(
                      children: [
                        _ChipTag(text: e.sportsCategory.isEmpty ? 'Category' : e.sportsCategory),
                        const SizedBox(width: 8),
                        _ChipTag(text: e.activityCategory.isEmpty ? 'Category' : e.activityCategory),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            child: Text(
                              _formatDate(e.startTime),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            centerText: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            child: Text(
                              _formatTimeRange(e.startTime, e.endTime),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            centerText: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            child: RichText(
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${e.location}\n',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                      height: 1.1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: e.address,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            centerText: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      e.description.isEmpty ? 'Description.' : e.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isBooking
                                  ? null
                                  : () async {
                                      if (!request.loggedIn) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginPage(),
                                          ),
                                        );
                                        return;
                                      }

                                      final ok = await _showJoinConfirmationDialog();
                                      if (ok != true) return;

                                      await _joinEvent(request);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7F50),
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                elevation: 5,
                              ),
                              child: Text(
                                _isBooking ? 'Booking...' : 'Book Event',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bookmark tapped (belum dihubungkan).')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
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
          color: Color(0xFFFF7F50),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final bool centerText;

  const _InfoCard({
    required this.child,
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
        child: child,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white, // ← INI YANG KURANG TADI
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
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
