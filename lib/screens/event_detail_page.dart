import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/models/models.dart';
import 'package:sportnet/screens/authentication/login_page.dart';
import 'package:sportnet/screens/forum/forum_page.dart';
import 'package:sportnet/screens/review/review_page.dart';
import 'package:sportnet/screens/profile/profile.dart';
import 'package:sportnet/widgets/user_list.dart';

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
      final url = '$_baseUrl/event/${widget.event.id}/join/';
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
    final request = context.watch<CookieRequest>();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildImageHeader(screenHeight),

          Positioned.fill(
            top: screenHeight * 0.30, 
            child: _buildContentSheet(context, e, request),
          ),

          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: _CircleIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // helper widgets
  Widget _buildImageHeader(double screenHeight) {
    final headerUrl = _proxyImageUrl(widget.event.thumbnail);
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: screenHeight * 0.40,
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
    );
  }

  Widget _buildContentSheet(BuildContext context, dynamic e, dynamic request) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), 
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori
            Row(
              children: [
                _ChipTag(text: e.sportsCategory.isEmpty ? 'Category' : e.sportsCategory),
                const SizedBox(width: 8),
                _ChipTag(text: e.activityCategory.isEmpty ? 'Category' : e.activityCategory),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    e.name.isEmpty ? 'Event Name' : e.name,
                    style: const TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.w800,
                      height: 1.1,
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
            const SizedBox(height: 20),

            _buildInfoRow(e),
            
            const SizedBox(height: 24),

            Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[900]),
            ),
            const SizedBox(height: 8),
            Text(
              e.description.isEmpty ? 'No description provided.' : e.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),

            _buildOrganizerInfo(e),

            const SizedBox(height: 24),

            Divider(color: Colors.grey.shade200, thickness: 1),
            const SizedBox(height: 16),

            _buildAttendeesSection(e),

            const SizedBox(height: 30),

            _buildBottomActions(context, request, e),
            
            const SizedBox(height: 18),

            _buildExtraActions(context, e),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(dynamic e) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            centerText: true,
            child: Text(
              _formatDate(e.startTime),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, height: 1.1),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoCard(
            centerText: true,
            child: Text(
              _formatTimeRange(e.startTime, e.endTime),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, height: 1.1),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoCard(
            centerText: true,
            child: Column( // Menggunakan Column agar lebih rapi daripada RichText complex
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text(
                   e.location,
                   textAlign: TextAlign.center,
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                   style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black),
                 ),
                 if(e.address.isNotEmpty)
                   Text(
                     e.address,
                     textAlign: TextAlign.center,
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                   ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, dynamic request, dynamic e) {
    return Row(
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
                          MaterialPageRoute(builder: (_) => const LoginPage()),
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
              child: _isBooking 
                ? const SizedBox(
                    height: 24, 
                    width: 24, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                  )
                : const Text(
                    'Book Event',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              const SnackBar(content: Text('Bookmark tapped (Feature coming soon).')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExtraActions(BuildContext context, dynamic e) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            label: 'Forum',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ForumPage(eventId: e.id, eventName: e.name),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ActionCard(
            label: 'Review',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewPage(eventId: e.id, eventName: e.name),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerInfo(Event event) {
    final String organizerName = event.organizerName.isNotEmpty ? event.organizerName : "Organizer";
    final String organizerImg = event.organizerPicture;
    final String organizerUsername = event.organizerUsername;

    return InkWell(
      onTap: () {
        if (organizerUsername.isNotEmpty && organizerUsername != "no_user") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(username: organizerUsername),
            ),
          );
        }
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: (organizerImg.isNotEmpty)
                    ? NetworkImage(_proxyImageUrl(organizerImg))
                    : const AssetImage('assets/image/profile-default.png') as ImageProvider,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Organized by:",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  organizerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _primaryOrange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildAttendeesSection(Event event) {
    final List<String> avatars = event.attendeeImages;
    final int current = event.attendeesCount;
    final int max = event.capacity;

    final String attendeesApiUrl = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/event/json/${event.id}/attendees/";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Attendees",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF7F50), 
          ),
        ),
        const SizedBox(height: 8),

        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => UserListDialog(
                title: "All Attendees",
                url: attendeesApiUrl,
              ),
            );
          },
          borderRadius: BorderRadius.circular(8), 
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0), 
            child: Row(
              children: [

                SizedBox(
                  width: avatars.isNotEmpty ? (30.0 * avatars.length + 15) : 45,
                  height: 40,
                  child: avatars.isEmpty
                      ? Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.group, color: Colors.grey),
                        )
                      : Stack(
                          children: List.generate(avatars.length, (index) {
                            return Positioned(
                              left: index * 24.0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: (avatars[index].isNotEmpty)
                                        ? NetworkImage(_proxyImageUrl(avatars[index]))
                                        : const AssetImage('assets/image/profile-default.png')
                                            as ImageProvider,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                ),
                const SizedBox(width: 8),

                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(
                        text: "$current",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D5CFF),
                        ),
                      ),
                      TextSpan(
                        text: "/$max",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
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
