import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

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

  List<dynamic> _posts = [];

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

  // =====================================================
  // GET FORUM LIST
  // =====================================================
  Future<void> _fetchForum() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        "http://127.0.0.1:8000/forum/api/list/${widget.eventId}/",
      );

      if (response is List) {
        setState(() {
          _posts = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _posts = [];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _posts = [];
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // POST FORUM MESSAGE
  // =====================================================
  Future<void> _sendForum() async {
    if (_controller.text.trim().isEmpty) return;

    final request = context.read<CookieRequest>();

    setState(() {
      _isSending = true;
    });

    try {
      final response = await request.post(
        "http://127.0.0.1:8000/forum/api/add/${widget.eventId}/",
        {
          "content": _controller.text.trim(),
        },
      );

      if (response != null && response["success"] == true) {
        _controller.clear();
        await _fetchForum();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // =====================================================
  // UI
  // =====================================================
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
                      ? const Center(
                          child: Text("Belum ada diskusi"),
                        )
                      : ListView.builder(
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  post["username"] ?? "User",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle:
                                    Text(post["content"] ?? ""),
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
