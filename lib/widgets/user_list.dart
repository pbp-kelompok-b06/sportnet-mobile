// widgets/user_list.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/screens/profile/profile.dart'; 

class UserListDialog extends StatelessWidget {
  final String title;
  final String url;

  const UserListDialog({
    super.key, 
    required this.title, 
    required this.url
  });

  // Helper untuk fix URL gambar
  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    return "https://anya-aleena-sportnet.pbp.cs.ui.ac.id$url";
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, 
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),

            // Content List
            Flexible(
              child: FutureBuilder(
                future: request.get(url), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  print("Data Snapshot: ${snapshot.data}");

                  List<dynamic> data = [];
                  if (snapshot.data != null) {
                    // Logic aman buat ambil data
                    if (snapshot.data is Map && snapshot.data['data'] != null) {
                       data = snapshot.data['data'];
                    } else if (snapshot.data is List) {
                       data = snapshot.data;
                    }
                  }

                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 40, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text(
                            "No $title yet.",
                            style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: data.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = data[index];

                      // Fallback nama yang aman
                      String name = item['full_name'] ?? item['organizer_name'] ?? "User";
                      String username = item['username'] ?? "";
                      String rawPhotoUrl = item['profile_picture'] ?? "";
                      String finalPhotoUrl = _fixImageUrl(rawPhotoUrl);

                      return InkWell(
                        onTap: () {
                          // Tutup dialog dulu, baru pindah
                          Navigator.pop(context); 
                          if (username.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(username: username),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: (finalPhotoUrl.isNotEmpty)
                                      ? NetworkImage(finalPhotoUrl)
                                      : const AssetImage('assets/image/profile-default.png') as ImageProvider,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Teks Nama & Username
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (username.isNotEmpty)
                                    Text(
                                      "@$username",
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}