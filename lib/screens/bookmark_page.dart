// lib/screens/bookmark_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../widgets/event_card.dart';
import '../models/bookmarks.dart';
import '../screens/authentication/login_page.dart';
import '../screens/event_detail_page.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final request = context.read<CookieRequest>();
      if (!request.loggedIn) return; // jangan load, jangan redirect
      await context.read<BookmarkProvider>().loadBookmarks(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarkProvider>();
    final request = context.watch<CookieRequest>();
    final bookmarks = provider.bookmarks;
    const Color primaryOrange = Color(0xFFF0544F);

    if (!request.loggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text("Bookmarks")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Please log in to view your bookmarks.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primaryOrange),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to load bookmark:\n${provider.errorMessage}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    if (provider.bookmarks.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No bookmarks yet.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: provider.bookmarks.length,
        itemBuilder: (context, index) {
          final b = provider.bookmarks[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailPage(event: b.event),
                      ),
                    );

                    // refresh bookmarks
                    final request = context.read<CookieRequest>();
                    await context.read<BookmarkProvider>().loadBookmarks(request);
                  },
                  child: SizedBox(
                    height: 170,
                    child: EventCard(event: b.event),
                  ),
                ),

                const SizedBox(height: 10),

                // Notes card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                    color: Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(b.note.isEmpty ? 'No notes yet.' : b.note),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final request = context.read<CookieRequest>();
                          final controller = TextEditingController(text: b.note);

                          final newNote = await showDialog<String?>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit note'),
                              content: TextField(controller: controller, maxLines: 3),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, controller.text),
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );

                          if (newNote != null) {
                            await provider.updateNote(request, b.eventId, newNote);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );        
        },
      ),
    );
  }
}