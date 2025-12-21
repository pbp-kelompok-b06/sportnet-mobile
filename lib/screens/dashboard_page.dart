import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportnet/models/dashboard.dart';
import 'package:sportnet/widgets/event_card.dart';
import 'package:sportnet/screens/event_detail_page.dart';
import 'package:sportnet/screens/authentication/login_page.dart';

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
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1600),
      ),
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
        appBar: AppBar(title: const Text("Dashboard")),
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
        actions: [
          IconButton(
            onPressed: () async {
              await prov.refreshAll(request);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => prov.refreshAll(request),
        color: primaryOrange,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (prov.pins.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "No pinned events yet.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              Column(
                children: prov.pins.map((p) {
                  final isLeftDisabled = p.position <= 1;
                  final isRightDisabled = p.position >= prov.pins.length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailPage(event: p.event),
                              ),
                            );
                          },
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: EventCard(event: p.event),
                          ),
                        ),

                        // pin icon pojok kanan atas (unpin)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Material(
                            color: Colors.white.withOpacity(0.85),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.push_pin, size: 20),
                              onPressed: () async {
                                final msg = await prov.togglePin(request, p.event.id);
                                if (msg != null) _toast(msg);
                              },
                            ),
                          ),
                        ),

                        // tombol < >
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Row(
                            children: [
                              _MoveBtn(
                                icon: Icons.chevron_left,
                                disabled: isLeftDisabled,
                                onTap: () async {
                                  final msg = await prov.movePin(request, p.event.id, "left");
                                  if (msg != null) _toast(msg);
                                },
                              ),
                              const SizedBox(width: 6),
                              _MoveBtn(
                                icon: Icons.chevron_right,
                                disabled: isRightDisabled,
                                onTap: () async {
                                  final msg = await prov.movePin(request, p.event.id, "right");
                                  if (msg != null) _toast(msg);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),

            // ===== My Events Section =====
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
                  final e = prov.myEvents[idx];
                  final pinned = prov.isPinned(e.id);

                  return Stack(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
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

                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: Colors.white.withOpacity(0.85),
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              pinned ? Icons.push_pin : Icons.push_pin_outlined,
                              size: 20,
                            ),
                            onPressed: () async {
                              final msg = await prov.togglePin(request, e.id);
                              if (msg != null) _toast(msg);
                            },
                          ),
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
}

class _MoveBtn extends StatelessWidget {
  final IconData icon;
  final bool disabled;
  final VoidCallback onTap;

  const _MoveBtn({
    required this.icon,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.35 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}