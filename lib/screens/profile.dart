import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/screens/login_page.dart';


class ProfilePage extends StatefulWidget {
  final String? username; // null = lihat profile sendiri

  const ProfilePage({super.key, this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _primaryOrange = const Color(0xFFFF7F50);

  // Variabel State
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
    });
  }

  Future<void> _fetchProfile() async {
    final request = context.read<CookieRequest>();
    
    // Tentukan URL
    String url;
    if (widget.username != null) {
      // Orang lain
      url = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/profile/api/${widget.username}/";
    } else {
      // Sendiri
      url = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/profile/api/"; 
    }

    try {
      final response = await request.get(url);
      
      // Handle error dari Django
      if (response['status'] == 'error' || response['detail'] == 'Invalid token') {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sesi habis, silakan login kembali.")),
           );
           // TENDANG KE LOGIN PAGE
           Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
           );
         }
         return;
      } else {
        setState(() {
          _profileData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat profil: $e";
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context){
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tampilkan pesan error (opsional, bisa dipersingkat)
                Text(
                  "Gagal memuat profil. Sepertinya sesi Anda telah habis.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  "Detail: $_errorMessage", 
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                
                // TOMBOL PENYELAMAT: LOGIN ULANG
                ElevatedButton(
                  onPressed: () {
                    // Arahkan ke Login Page dan hapus history sebelumnya
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Login Ulang"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // parsing data
    final user = _profileData!['user'];
    final profile = _profileData!['profile'];
    final stats = profile['stats'];
    final isMe = user['is_me'];
    final role = user['role'];

    // data text
    String name = role == 'participant' 
        ? (profile['full_name'] ?? "No Name") 
        : (profile['organizer_name'] ?? "No Name");

    String image = profile['profile_picture'] ?? ""; // url gambar

    // Handling gambar URL (tambahkan base URL jika dari Django local)
    if (image.isNotEmpty && !image.startsWith('http')) {
      image = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id$image"; 
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // header
            _buildHeader(name, user['username'], role, image),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // stats card
                  _buildStatsCard(role, stats),
                  const SizedBox(height: 16),

                  // about card
                  _buildAboutCard(role, profile),
                  const SizedBox(height: 16),

                  // action buttons
                  if (isMe) _buildActionButtons(),
                  const SizedBox(height: 24),

                  // event section
                  if (role == 'participant' && profile['booked_events'] != null) ...[
                     _buildEventSection("Upcoming Activities", profile['booked_events']['upcoming']),
                     const SizedBox(height: 20),
                     _buildEventSection("History", profile['booked_events']['past']),
                  ] else if (role == 'organizer' && profile['organized_events'] != null) ...[
                     _buildEventSection("Created Events", profile['organized_events']),
                  ],
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// widgets builder

Widget _buildHeader(String name, String username, String role, String imageUrl) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Banner Gradient
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryOrange, _primaryOrange.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Back Button (Kalau liat profil orang lain)
        if (widget.username != null)
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

        // Content Container
        Container(
          margin: const EdgeInsets.only(top: 120),
          padding: const EdgeInsets.only(top: 60, bottom: 20),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.grey, // Placeholder
          ),
        ),
        
        // Avatar & Text
        Positioned(
          top: 100, // mengatur posisi overlap
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imageUrl.isNotEmpty 
                      ? NetworkImage(imageUrl) 
                      : const AssetImage('image/profile-default.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "@$username",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: role == 'participant' ? Colors.blue[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: role == 'participant' ? Colors.blue : Colors.orange,
                    width: 0.5
                  )
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold,
                    color: role == 'participant' ? Colors.blue : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String role, Map<String, dynamic> stats) {
    String label = role == 'organizer' ? "Pengikut" : "Mengikuti";
    int count = role == 'organizer' ? stats['followers_count'] : stats['following_count'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 4),
              Text("$count Orang", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          // Tombol Chevron untuk liat detail
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            radius: 16,
            child: const Icon(Icons.chevron_right, color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _buildAboutCard(String role, Map<String, dynamic> profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tentang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          Text(
            (profile['about'] != null && profile['about'] != "-") 
                ? profile['about'] 
                : "Belum ada deskripsi diri.",
            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          
          if (role == 'participant') ...[
            _buildInfoRow(Icons.location_on, "Domisili", profile['location'] ?? "-"),
            _buildInfoRow(Icons.cake, "Tanggal Lahir", profile['birth_date'] ?? "-"),
            _buildInfoRow(Icons.sports_tennis, "Minat", profile['interests'] ?? "-"),
          ] else ...[
            _buildInfoRow(Icons.email, "Email", profile['contact_email'] ?? "-"),
            _buildInfoRow(Icons.phone, "Telepon", profile['contact_phone'] ?? "-"),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
               // TODO: Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Edit Profile Clicked")));
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Edit Profil"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showDeleteConfirmDialog,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text("Hapus Akun"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventSection(String title, List<dynamic> events) {
    final Color primaryOrange = const Color(0xFFFF7F50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // judul
        Row(
          children: [
            Container(width: 4, height: 20, color: primaryOrange, margin: const EdgeInsets.only(right: 8)),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        
        // jika event kosong
        if (events.isEmpty) 
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid)
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 40, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text("Tidak ada aktivitas.", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          )
        else 
          // jika ada event
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                // image logic
                String? thumbnailUrl = event['thumbnail'];
                Widget imageWidget;

                if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
                  // Cek URL lengkap atau relatif
                  if (!thumbnailUrl.startsWith('http')) {
                    thumbnailUrl = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id$thumbnailUrl"; 
                  }
                  
                  imageWidget = Image.network(
                    thumbnailUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, _) => Image.asset(
                      'assets/image/no-image.jpg', 
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  // Fallback Asset
                  imageWidget = Image.asset(
                    'assets/image/no-image.jpg', 
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                }

                // return widget card
                return Container(
                  width: 280, 
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: imageWidget, 
                      ),
                      
                      // Info Judul & Waktu
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['name'], 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event['start_time'], 
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Akun?"),
          content: const Text("Tindakan ini permanen dan tidak dapat dibatalkan. Semua data profil dan riwayat akan hilang."),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            
            // Tombol Hapus
            TextButton(
              onPressed: () async {
                 Navigator.of(context).pop();
                 
                 final request = context.read<CookieRequest>();
                 
                 try {
                   final response = await request.post(
                     "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/profile/api/delete/", 
                     {}, 
                   );

                   // Cek Status
                   if (response['status'] == 'success') {
                      if(context.mounted) {
                          Navigator.pushAndRemoveUntil(
                              context, 
                              MaterialPageRoute(builder: (_) => const LoginPage()), 
                              (r) => false
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Akun berhasil dihapus."))
                          );
                      }
                   } else {
                      // Handle jika server menolak
                      if(context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response['message'] ?? "Gagal menghapus akun."))
                          );
                      }
                   }
                 } catch(e) {
                   if(context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text("Terjadi kesalahan: $e"))
                       );
                   }
                 }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}