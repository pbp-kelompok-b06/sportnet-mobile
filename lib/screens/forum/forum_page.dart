import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sportnet/screens/services/api_client.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportnet/models/forum.dart';

class ForumPage extends StatefulWidget {
  final String eventId;
  final String eventName;

  const ForumPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _controller = TextEditingController();

  bool _isSending = false;
  bool _isLoading = true;
  List<ForumPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchForum();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================
  // GET FORUM LIST
  // =========================
  Future<void> _fetchForum() async {
    CookieRequest request = context.read<CookieRequest>();
    try {
      final res = await request.get(
        "https:/anya-aleena-sportnet.pbp.cs.ui.ac.id/forum/api/list/${widget.eventId}/",
      );
      setState(() {
        _posts = (res["data"] as List).map((post) => ForumPost.fromJson(post)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Forum fetch error: $e");
      setState(() {
        _posts = [];
        _isLoading = false;
      });
    }
  }

  // =========================
  // POST FORUM
  // =========================
  Future<void> _sendForum() async {
    CookieRequest request = context.read<CookieRequest>();
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final res = await request.post(
        "https:/anya-aleena-sportnet.pbp.cs.ui.ac.id/forum/api/add/${widget.eventId}/",
        {"content": _controller.text.trim()},
      );

      if (res["success"] == true) {
        _controller.clear();
        await _fetchForum();
      }
    } catch (e) {
      debugPrint("Forum send error: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forum: ${widget.eventName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Tulis diskusi...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendForum,
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Kirim"),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                      ? const Center(child: Text("Belum ada diskusi"))
                      : ListView.builder(
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  post.author,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle:
                                    Text(post.message),
                              ),
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
