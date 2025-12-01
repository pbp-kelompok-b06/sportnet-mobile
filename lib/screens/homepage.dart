import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'notif_page.dart';
import 'package:sportnet/screens/login_page.dart';

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
    const PlaceholderWidget(title: 'Profile'),
  ];

  void _onItemTapped(int index) {
    if(index == 3){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else{
      setState(() {
        _selectedIndex = index;
      });
    }
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
      
      // PERBAIKAN: request.get() mengembalikan dynamic (JSON), bukan http.Response
      final response = await request.get('http://127.0.0.1:8000/event/json/');

      List<dynamic> data = [];

      // Logika untuk menangani berbagai kemungkinan format JSON
      if (response is List) {
        // Jika API langsung mengembalikan List: [{...}, {...}]
        data = response;
      } else if (response is Map && response.containsKey('events')) {
        // Jika API mengembalikan Object dengan key 'events': {"events": [...]}
        data = response['events'];
      } else if (response is Map) {
         // Fallback jika API mengembalikan Map tapi bukan struktur diatas, mungkin perlu disesuaikan
         // Namun biasanya endpoint /json/ django mengembalikan List.
         // Kita coba anggap ini error format jika tidak sesuai
         // Atau jika ini adalah endpoint yang mengembalikan list of objects (Django serialize),
         // response akan terbaca sebagai List, jadi blok ini mungkin jarang tersentuh
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
            const SearchInput(),
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
                itemCount: _events.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  return EventCard(event: _events[index]);
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
  const SearchInput({super.key});

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
      child: const Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search sports, categories, places',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
          Icon(Icons.search, color: Colors.grey, size: 24),
        ],
      ),
    );
  }
}

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
    const Color primaryOrange = Color(0xFFF0544F);
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
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade800),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateAndPlace,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 8,
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