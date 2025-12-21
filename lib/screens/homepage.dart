import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/models.dart';
import 'notif_page.dart';
import 'profile/profile.dart';
import 'package:sportnet/widgets/event_card.dart';
import 'package:sportnet/models/bookmarks.dart';
import 'bookmark_page.dart';
import 'package:sportnet/screens/event_detail_page.dart';
import '../screens/dashboard_page.dart';
import '../models/dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _primaryOrange = Color(0xFFF0544F);
  bool _isOrganizer = false;
  bool _roleLoaded = false;

  int _selectedIndex = 0;
  int _unreadCount = 0;
  Timer? _pollingTimer;
  // late final List<Widget> _pages; // Removed to allow dynamic updates
  List<Event> _events = [];

  Future<void> _fetchedEvents() async {
    try {
      // Mengambil instance CookieRequest dari Provider
      final request = context.read<CookieRequest>();
      final response = await request.get(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/event/json/',
      );
      List<dynamic> data = [];

      // Logika untuk menangani berbagai kemungkinan format JSON
      if (response is List) {
        data = response;
      } else if (response is Map && response.containsKey('events')) {
        data = response['events'];
      } else if (response is Map) {
        throw Exception("Format data tidak dikenali: $response");
      }

      // Konversi JSON ke List<Event>
      List<Event> events = [];
      for (var d in data) {
        if (d != null) {
          events.add(Event.fromJson(d));
        }
      }

      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
      if (mounted) {
        setState(() {
          _events = [];
        });
      }
    }
  }

  Future<void> _loadRole() async {
    try {
      final request = context.read<CookieRequest>();

      if (!request.loggedIn) {
        if (!mounted) return;
        setState(() {
          _isOrganizer = false;
          _roleLoaded = true;
        });
        return;
      }

      final res = await request.get(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/profile/api/',
      );

      final role = (res is Map && res['user'] is Map)
          ? (res['user']['role'] ?? '').toString()
          : '';

      if (!mounted) return;
      setState(() {
        _isOrganizer = (role == 'organizer');
        _roleLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOrganizer = false;
        _roleLoaded = true;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    // _pages initialization removed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUnreadCount();
      _fetchedEvents();
      _loadRole();
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _refreshUnreadCount();
    });
  }

  void _handleUnreadCountChanged(int count) {
    if (!mounted) return;
    setState(() {
      _unreadCount = count;
    });
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final request = context.read<CookieRequest>();
      if (!request.loggedIn) {
        _handleUnreadCountChanged(0);
        return;
      }

      final response = await request.get(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/notification/json/',
      );

      List<dynamic>? data;
      if (response is Map && response['notifications'] is List) {
        data = response['notifications'] as List<dynamic>;
      }

      if (data == null) return;

      final unread = data.where((item) {
        if (item is Map && item['is_read'] != null) {
          return item['is_read'] == false;
        }
        return false;
      }).length;

      _handleUnreadCountChanged(unread);
    } catch (e) {
      // Biarkan badge tidak berubah jika terjadi error
      debugPrint('Failed to refresh unread notifications: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeContent(),
      ChangeNotifierProvider(
        create: (_) => BookmarkProvider(),
        child: const BookmarkPage(),
      ),
    ];

    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.bookmark_outline),
        activeIcon: Icon(Icons.bookmark),
        label: '',
      ),
    ];
    if (_isOrganizer) {
      pages.add(
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
          child: const DashboardPage(),
        ),
      );
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: '',
        ),
      );
    }
    pages.add(
      NotificationsPage(
        onUnreadCountChanged: _handleUnreadCountChanged,
        events: _events,
      ),
    );
    items.add(
      BottomNavigationBarItem(
        icon: _buildNotificationIcon(isActive: false),
        activeIcon: _buildNotificationIcon(isActive: true),
        label: '',
      ),
    );
    pages.add(const ProfilePage());
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: '',
      ),
    );
    if (_selectedIndex >= pages.length) {
      _selectedIndex = pages.length - 1;
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: _selectedIndex,
        selectedItemColor: _primaryOrange,
        unselectedItemColor: Colors.grey[500],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }

  Widget _buildNotificationIcon({required bool isActive}) {
    final icon = isActive ? Icons.notifications : Icons.notifications_none;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (_unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: _primaryOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// --- KONTEN HALAMAN HOME ---
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Variabel state
  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Menggunakan addPostFrameCallback untuk memastikan context siap sebelum memanggil Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEvents();
    });
  }

  Future<void> _fetchEvents() async {
    try {
      // Mengambil instance CookieRequest dari Provider
      final request = context.read<CookieRequest>();
      final response = await request.get(
        'https://anya-aleena-sportnet.pbp.cs.ui.ac.id/event/json/',
      );
      List<dynamic> data = [];

      // Logika untuk menangani berbagai kemungkinan format JSON
      if (response is List) {
        data = response;
      } else if (response is Map && response.containsKey('events')) {
        data = response['events'];
      } else if (response is Map) {
        throw Exception("Format data tidak dikenali: $response");
      }

      // Konversi JSON ke List<Event>
      List<Event> events = [];
      for (var d in data) {
        if (d != null) {
          events.add(Event.fromJson(d));
        }
      }

      if (mounted) {
        setState(() {
          _events = events;
          _filteredEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Event> results = [];
    if (enteredKeyword.isEmpty) {
      // Jika kosong, tampilkan semua event
      results = _events;
    } else {
      // Filter berdasarkan nama, kategori, atau lokasi
      results = _events
          .where(
            (event) =>
                event.name.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ) ||
                event.sportsCategory.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ) ||
                event.location.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ),
          )
          .toList();
    }

    setState(() {
      _filteredEvents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF0544F);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'SportNet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SearchInput(onChanged: _runFilter),
            const SizedBox(height: 24),

            // TAMPILAN KONTEN BERDASARKAN STATE
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: primaryOrange),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Terjadi kesalahan saat memuat data.\nPastikan Anda terhubung ke internet.\n\nDetail: $_errorMessage",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (_events.isEmpty)
              const Center(
                child: Text(
                  'Tidak ada event ditemukan.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _filteredEvents.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EventDetailPage(event: _filteredEvents[index]),
                        ),
                      );
                    },
                    child: EventCard(event: _filteredEvents[index]),
                  );
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET PENDUKUNG ---

class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title Page',
        style: const TextStyle(fontSize: 20, color: Colors.grey),
      ),
    );
  }
}

class SearchInput extends StatelessWidget {
  // Tambahkan callback function
  final ValueChanged<String> onChanged;
  const SearchInput({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged, // Panggil fungsi saat teks berubah
              decoration: const InputDecoration(
                // Tambahkan const di sini
                hintText: 'Search sports, categories, places',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Icon(Icons.search, color: Colors.grey, size: 24),
        ],
      ),
    );
  }
}
