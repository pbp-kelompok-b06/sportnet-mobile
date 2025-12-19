// lib/screens/bookmark_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/bookmarks.dart';
import '../screens/authentication/login_page.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  void initState() {
    super.initState();
    // load data setelah build pertama
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final request = context.read<CookieRequest>();

      // belum login -> redirect ke log
      if (!request.loggedIn) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }

      // sudah login -> load bookmarks
      await context.read<BookmarkProvider>().loadBookmarks(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarkProvider>();
    const Color primaryOrange = Color(0xFFF0544F);

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

          return ListTile(
            title: Text(b.eventTitle),
            subtitle: Text(
              b.note.isEmpty ? 'No notes yet.' : b.note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              // nanti bisa diarahkan ke halaman detail event
            },
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final request = context.read<CookieRequest>();
                final controller = TextEditingController(text: b.note);

                final newNote = await showDialog<String?>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Edit note'),
                    content: TextField(
                      controller: controller,
                      maxLines: 3,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.text),
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
          );
        },
      ),
    );
  }
}