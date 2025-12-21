import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/screens/homepage.dart';
import 'package:sportnet/screens/authentication/login_page.dart';
import 'package:sportnet/screens/profile/edit_profile.dart';
import 'package:sportnet/widgets/user_list.dart';
import 'package:intl/intl.dart';
import 'package:sportnet/screens/event_detail_page.dart';
import 'package:sportnet/models/models.dart';
import 'package:sportnet/widgets/event_card.dart';


class ProfilePage extends StatefulWidget {
  final String? username; // null = lihat profile sendiri

  const ProfilePage({super.key, this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel State
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  bool _isFollowing = false;
  int _followerCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
    });
  }

  Future<void> _fetchProfile() async {
    final request = context.read<CookieRequest>();
    
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
              const SnackBar(
                content: Text("Sesi telah habis, silakan login kembali."),
                backgroundColor: Colors.red,
              ),
           );
           
           Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
           );
         }
         return;
      }
        setState(() {
          _profileData = response;
          _isLoading = false;

          if(response['is_following'] != null){
            _isFollowing = response['is_following'];
          }

          if (response['profile']['stats'] != null) {
            _followerCount = response['profile']['stats']['followers_count'] ?? 0;
          }
        });
    } catch (e) {
      if (mounted) {
         Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
         );
      }
    }
  }

  Future<void> _toggleFollow() async {
  final request = context.read<CookieRequest>();
  final organizerId = _profileData!['user']['id'];

  String url = _isFollowing
      ? "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/follow/$organizerId/unfollow/"
      : "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/follow/$organizerId/follow/";

  try {
    final response = await request.post(url, {});
    
    if (!mounted) return; 

      if (response['status'] == 'success') {
        setState(() {
          _isFollowing = !_isFollowing;
          if (_isFollowing) {
            _followerCount++;
          } else {
            _followerCount--;
          }

          if (_profileData!['profile']['stats'] != null) {
             _profileData!['profile']['stats']['followers_count'] = _followerCount;
          }
        });
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response['message']),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
    }
  } catch (e) {
    if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal terhubung ke server")));
      }
  }
}
  
  @override
  Widget build(BuildContext context){
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profileData == null) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // parsing data
    final user = _profileData!['user'];
    final profile = _profileData!['profile'];
    final stats = profile['stats'];
    final role = user['role'];

    // data text
    String name = profile['full_name'] ?? profile['organizer_name'] ?? "No Name";
    String image = profile['profile_picture'] ?? ""; // url gambar

    // Handling gambar URL
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

                  // event section
                  if (role == 'participant' && profile['booked_events'] != null) ...[
                     _buildEventSection("Upcoming Events", profile['booked_events']['upcoming']),
                     const SizedBox(height: 20),
                     _buildEventSection("Past Events", profile['booked_events']['past']),
                  ] else if (role == 'organizer' && profile['organized_events'] != null) ...[
                     _buildEventSection("Created Events", profile['organized_events']),
                  ],
                  const SizedBox(height: 40),
                  
                  _buildActionButtons(), 
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// widgets builder

Widget _buildHeader(
    String name, String username, String role, String imageUrl) {
    final Color topOrange = const Color(0xFFFFAB91);
    final Color bottomPeach = const Color(0xFFFFCCBC);
    final Color nameColor = const Color(0xFFE64A19);
    final Color roleColor = Colors.grey.shade600;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            ClipPath(
              clipper: HeaderWaveClipper(),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [topOrange, bottomPeach],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

             Positioned(
              top: 50, 
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.username != null)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ) else const SizedBox(width: 24),
                ],
              ),
            ),

            Positioned(
              bottom: -30,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/image/profile-default.png')
                              as ImageProvider,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Nama User
        Text(
          name,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: nameColor,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Username & Role
        Text(
          "@$username  •  ${role.toUpperCase()}",
          style: TextStyle(
            color: roleColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 20),

        if (widget.username == null) 
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(userData: _profileData!),
                ),
              );

              if (result == true) {
                _fetchProfile();
              }
            },
            icon: const Icon(Icons.edit, size: 20),
            label: const Text("Edit Profile"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7F50),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          )
        
        else if (role.toLowerCase() == 'organizer')
           ElevatedButton(
            onPressed: _toggleFollow, 
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollowing ? Colors.grey[400] : const Color(0xFFFF7F50),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(), 
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              elevation: 4, 
            ),
            child: Text(
              _isFollowing ? "Unfollow" : "Follow",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }
  

Widget _buildStatsCard(String role, Map<String, dynamic> stats) {

  String label;
  int count;
  String titleDialog;
  String urlEndpoint;
  String currentProfileUsername = widget.username ?? _profileData!['user']['username'];
  String baseUrl = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/follow";

  if (role == 'participant') {
    label = "Following";
    count = stats['following_count'] ?? 0;
    titleDialog = "Following List";
    urlEndpoint = "$baseUrl/participant/$currentProfileUsername/following/";

  } else { 
    // Role == Organizer
    label = "Followers";
    count = stats['followers_count'] ?? 0;
    titleDialog = "Followers List";
    urlEndpoint = "$baseUrl/organizer/$currentProfileUsername/followers/";
  }

  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => UserListDialog(
              title: titleDialog,
              url: urlEndpoint,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                "$count",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
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
          const Text("About", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          Text(
            (profile['about'] != null && profile['about'] != "-") 
                ? profile['about'] 
                : "No description available.", 
            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          
          if (role == 'participant') ...[
            _buildInfoRow(Icons.location_on, "Location", profile['location'] ?? "-"), 
            _buildInfoRow(
              Icons.cake, 
              "Birth Date", 
              profile['birth_date'] != null && profile['birth_date'] != "-" && profile['birth_date'].isNotEmpty
                ? DateFormat('dd/MM/yyyy').format(DateTime.parse(profile['birth_date']))
                : "-",
            ),
            _buildInfoRow(Icons.sports_tennis, "Interests", profile['interests'] ?? "-"),
          ] else ...[
            _buildInfoRow(Icons.email, "Email", profile['contact_email'] ?? "-"),
            _buildInfoRow(Icons.phone, "Phone", profile['contact_phone'] ?? "-"),
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
    final user = _profileData!['user'];
    final bool isMe = user['is_me'];
    if (isMe) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final request = context.read<CookieRequest>();
                
                final response = await request.logout(
                    "https:/anya-aleena-sportnet.pbp.cs.ui.ac.id/authenticate/api/logout/"
                );

                if (!mounted) return;

                if (response['status']) {
                  String message = response['message'];

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'])),
                  );
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                elevation: 0,
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
              label: const Text("Delete Account"),
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

    return const SizedBox.shrink();
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
                Text("No Activities yet.", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          )
        else 
          // jika ada event
          SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            physics: const BouncingScrollPhysics(), 
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final eventObj = Event.fromJson(events[index]);

              return Container(
                width: 280, 
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(event: eventObj),
                      ),
                    );
                  },
                  child: EventCard(event: eventObj),
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
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Account?"),
          content: const Text("This action is permanent. Your account will be permanently deleted."), 
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)), // Batal
            ),
            TextButton(
              onPressed: () async {
                final request = context.read<CookieRequest>();
                try {
                  final response = await request.post(
                    "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/profile/api/delete/",
                    {},
                  );

                  if (response['status'] == 'success') {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    if (!mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()), 
                      (r) => false,
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account deleted successfully.")) 
                    );

                  } else {
                    // Handle Gagal
                    if (dialogContext.mounted) {
                       Navigator.of(dialogContext).pop();
                    }
                    
                    if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text(response['message'] ?? "Failed to delete account.")) 
                       );
                    }
                  }
                } catch (e) {
                   // Handle Error
                   if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                   }
                   if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e"))
                      );
                   }
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), 
            ),
          ],
        );
      },
    );
  }
}

class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    
    path.lineTo(0, size.height); 
    var controlPoint = Offset(size.width / 2, size.height - 100); 

    var endPoint = Offset(size.width, size.height);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}