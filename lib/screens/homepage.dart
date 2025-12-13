import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/models.dart';
import 'notif_page.dart';
import 'profile/profile.dart';
import 'package:sportnet/widgets/event_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const PlaceholderWidget(title: 'Bookmarks'),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF0544F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryOrange,
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
      
      final response = await request.get('https://anya-aleena-sportnet.pbp.cs.ui.ac.id/event/json/');
      print(request.loggedIn);
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
          .where((event) =>
              event.name.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              event.sportsCategory.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              event.location.toLowerCase().contains(enteredKeyword.toLowerCase()))
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
            SearchInput(
              onChanged: _runFilter, 
            ),
            const SizedBox(height: 24),

            // TAMPILAN KONTEN BERDASARKAN STATE
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: primaryOrange))
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
              const Center(child: Text('Tidak ada event ditemukan.', style: TextStyle(color: Colors.grey)))
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
                  return EventCard(event: _filteredEvents[index]);
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
              decoration: const InputDecoration( // Tambahkan const di sini
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
