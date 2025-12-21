import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sportnet/screens/services/api_client.dart';

class ReviewPage extends StatefulWidget {
  final String eventId;
  final String eventName;

  const ReviewPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _commentController = TextEditingController();

  int _rating = 5;
  bool _isSending = false;
  bool _isLoading = true;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // =========================
  // GET REVIEW LIST
  // =========================
  Future<void> _fetchReviews() async {
    try {
      final res = await ApiClient.dio.get(
        "/review/api/list/${widget.eventId}/",
      );

      setState(() {
        _reviews = res.data is List ? res.data : [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Review fetch error: $e");
      setState(() {
        _reviews = [];
        _isLoading = false;
      });
    }
  }

  // =========================
  // POST REVIEW
  // =========================
  Future<void> _sendReview() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final res = await ApiClient.dio.post(
        "/review/api/add/${widget.eventId}/",
        data: FormData.fromMap({
          "rating": _rating,
          "comment": _commentController.text.trim(),
        }),
      );

      if (res.data["success"] == true) {
        _commentController.clear();
        await _fetchReviews();
      }
    } catch (e) {
      debugPrint("Review send error: $e");
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
        title: Text("Review: ${widget.eventName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<int>(
              value: _rating,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 1, child: Text("1 - Sangat Buruk")),
                DropdownMenuItem(value: 2, child: Text("2 - Buruk")),
                DropdownMenuItem(value: 3, child: Text("3 - Cukup")),
                DropdownMenuItem(value: 4, child: Text("4 - Baik")),
                DropdownMenuItem(value: 5, child: Text("5 - Sangat Baik")),
              ],
              onChanged: (v) => setState(() => _rating = v ?? 5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: "Tulis review...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendReview,
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Kirim Review"),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reviews.isEmpty
                      ? const Center(child: Text("Belum ada review"))
                      : ListView.builder(
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  "⭐ ${review["rating"]}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle:
                                    Text(review["comment"] ?? ""),
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
