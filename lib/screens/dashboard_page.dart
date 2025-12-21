import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportnet/models/dashboard.dart';
import 'package:sportnet/widgets/event_card.dart';
import 'package:sportnet/screens/event_detail_page.dart';
import 'package:sportnet/screens/authentication/login_page.dart';
import 'package:sportnet/screens/event_form_page.dart';
import 'package:sportnet/models/models.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color primaryOrange = Color(0xFFF0544F);

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1600)),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final request = context.read<CookieRequest>();

      if (!request.loggedIn) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }

      await context.read<DashboardProvider>().refreshAll(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    final prov = context.watch<DashboardProvider>();

    if (prov.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryOrange)),
      );
    }

    if (prov.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Failed to load dashboard:\n${prov.errorMessage}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => prov.refreshAll(request),
        color: primaryOrange,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== HEADER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6A3A), Color(0xFFF0544F)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Here's a strategic overview of your managed events.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== STATS =====
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_month_outlined,
                    label: "Total Events",
                    value: prov.totalEvents.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.groups_outlined,
                    label: "Total Attendees",
                    value: prov.totalAttendees.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ===== CREATE =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventFormPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Create New Event",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),

            // ===== Pinned Section =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pinned Events",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  "${prov.pins.length}/${prov.maxPinned}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (prov.pins.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("No pinned events yet.", style: TextStyle(color: Colors.grey)),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  const crossAxisCount = 2;
                  const spacing = 16.0;

                  final itemWidth =
                      (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

                  final itemHeight = itemWidth / 1.5; // karena childAspectRatio = 1.5

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: prov.pins.map((p) {
                      final e = p.event;
                      final key = ValueKey("pin-${e.id}");

                      return DragTarget<String>(
                        onWillAccept: (draggedId) => draggedId != null && draggedId != e.id,
                        onAccept: (draggedEventId) async {
                          // target position = posisi card yang baru
                          final targetPos = p.position;

                          final msg = await prov.movePinToPosition(
                            request,
                            draggedEventId,
                            targetPos,
                          );
                          if (msg != null) _toast(msg);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHover = candidateData.isNotEmpty;

                          return LongPressDraggable<String>(
                            data: e.id,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: Opacity(
                                  opacity: 0.9,
                                  child: EventCard(event: e),
                                ),
                              ),
                            ),
                            childWhenDragging: SizedBox(
                              width: itemWidth,
                              height: itemHeight,
                              child: Opacity(
                                opacity: 0.35,
                                child: EventCard(event: e),
                              ),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: itemWidth,
                              height: itemHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: isHover
                                    ? Border.all(color: primaryOrange, width: 2)
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EventDetailPage(event: e),
                                        ),
                                      );
                                    },
                                    child: EventCard(event: e),
                                  ),

                                  // unpin (pojok kanan atas)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Material(
                                      color: Colors.white.withOpacity(0.85),
                                      shape: const CircleBorder(),
                                      child: IconButton(
                                        icon: const Icon(Icons.push_pin, size: 20),
                                        onPressed: () async {
                                          final msg = await prov.togglePin(request, e.id);
                                          if (msg != null) _toast(msg);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),

            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),

            // ===== MY EVENTS =====
            const Text(
              "My Events",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            if (prov.myEvents.isEmpty)
              Text("You have no events.", style: TextStyle(color: Colors.grey[600]))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prov.myEvents.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, idx) {
                  // Di dalam GridView.builder -> itemBuilder:
final e = prov.myEvents[idx];
final pinned = prov.isPinned(e.id.toString());

return Stack(
  children: [
    GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailPage(event: e)),
      ),
      child: EventCard(event: e),
    ),
    
    // Tombol Actions di pojok kanan atas
    Positioned(
      top: 5,
      right: 5,
      child: Row(
        children: [
          // Tombol EDIT
          _CircleActionBtn(
            icon: Icons.edit,
            color: Colors.blue,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventFormPage(event: e)),
              );
              if (mounted) prov.refreshAll(request); // Refresh data setelah balik
            },
          ),
          const SizedBox(width: 4),
          // Tombol DELETE
          _CircleActionBtn(
            icon: Icons.delete_forever,
            color: Colors.red,
            onTap: () => _confirmDelete(e, request, prov),
          ),
        ],
      ),
    ),
  ],
);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Event e, CookieRequest request, DashboardProvider prov) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Hapus Event?"),
      content: Text("Apakah Anda yakin ingin menghapus '${e.name}'?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final response = await request.post(
              "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/event/delete-flutter/${e.id}/",
              {},
            );
            if (response["status"] == "success") {
              _toast("Event dihapus");
              prov.refreshAll(request);
            } else {
              _toast("Gagal menghapus: ${response["message"]}");
            }
          },
          child: const Text("Hapus", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
}


// UI COMPONENTS
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF0544F).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFF0544F)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}