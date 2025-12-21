import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  // === NGIKUT EVENT DETAIL (BOOK EVENT BUTTON) ===
  static const Color _btnOrange = Color(0xFFFF7F50);

  // Background gradient yang mirip create_event.html
  static const Color _bgTop = Color(0xFFFFF3F0);
  static const Color _bgBottom = Color(0xFFFFE2DB);

  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _feeController = TextEditingController();
  final _capacityController = TextEditingController();

  // Variables
  String? _selectedSportsCategory;
  String? _selectedActivityCategory;
  DateTime? _startTime;
  DateTime? _endTime;

  // Paid checkbox logic
  bool _isPaid = false;

  final List<String> _sportsOptions = [
    'Badminton',
    'Basketball',
    'Futsal',
    'Soccer',
    'Swimming',
    'Running',
    'Gym',
    'Yoga',
    'Tennis',
    'Volleyball'
  ];

  final List<String> _activityOptions = [
    'Sparring',
    'Tournament',
    'Fun Match',
    'Training',
    'Coaching'
  ];

  @override
  void initState() {
    super.initState();
    _feeController.text = "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _thumbnailController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _feeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(BuildContext context, {required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart ? now : (_startTime ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _btnOrange),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return null;

    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _btnOrange),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // === UI HELPERS (ngikut style HTML: label kiri + field kanan) ===
  Widget _rowField({
    required String label,
    required Widget field,
    bool alignTop = false,
  }) {
    return Row(
      crossAxisAlignment: alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: Padding(
            padding: EdgeInsets.only(top: alignTop ? 12 : 0),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280), // mirip text-400
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: field),
      ],
    );
  }

  InputDecoration _pillDecoration(String hint, {bool disabledLook = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: disabledLook ? Colors.grey[100] : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: _btnOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Event",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _btnOrange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.72), // bg-white/70 vibe
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                      color: Colors.black.withOpacity(0.08),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          "Create Event",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF7F50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Host your own SportNet event!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 26),

                        // Name
                        _rowField(
                          label: "Name",
                          field: TextFormField(
                            controller: _nameController,
                            decoration: _pillDecoration(""),
                            validator: (v) => (v == null || v.trim().isEmpty) ? "Name wajib diisi" : null,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Description
                        _rowField(
                          label: "Description",
                          alignTop: true,
                          field: TextFormField(
                            controller: _descController,
                            decoration: _pillDecoration(""),
                            minLines: 3,
                            maxLines: 6,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Thumbnail
                        _rowField(
                          label: "Thumbnail",
                          field: TextFormField(
                            controller: _thumbnailController,
                            decoration: _pillDecoration(""),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Date & Time (start - end)
                        _rowField(
                          label: "Date & Time",
                          field: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final dt = await _pickDateTime(context, isStart: true);
                                    if (dt != null) setState(() => _startTime = dt);
                                  },
                                  child: InputDecorator(
                                    decoration: _pillDecoration("dd-mm-yyyy --:--"),
                                    child: Text(
                                      _startTime != null
                                          ? DateFormat('dd-MM-yyyy  HH:mm').format(_startTime!)
                                          : "dd-mm-yyyy --:--",
                                      style: TextStyle(
                                        color: _startTime == null ? Colors.grey[500] : Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text("–", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final dt = await _pickDateTime(context, isStart: false);
                                    if (dt != null) setState(() => _endTime = dt);
                                  },
                                  child: InputDecorator(
                                    decoration: _pillDecoration("dd-mm-yyyy --:--"),
                                    child: Text(
                                      _endTime != null
                                          ? DateFormat('dd-MM-yyyy  HH:mm').format(_endTime!)
                                          : "dd-mm-yyyy --:--",
                                      style: TextStyle(
                                        color: _endTime == null ? Colors.grey[500] : Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Location
                        _rowField(
                          label: "Location",
                          field: TextFormField(
                            controller: _locationController,
                            decoration: _pillDecoration(""),
                            validator: (v) => (v == null || v.trim().isEmpty) ? "Location wajib diisi" : null,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Address
                        _rowField(
                          label: "Address",
                          alignTop: true,
                          field: TextFormField(
                            controller: _addressController,
                            decoration: _pillDecoration(""),
                            minLines: 2,
                            maxLines: 5,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Sports Category
                        _rowField(
                          label: "Sports Category",
                          field: DropdownButtonFormField<String>(
                            value: _selectedSportsCategory,
                            items: _sportsOptions
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedSportsCategory = v),
                            decoration: _pillDecoration("---------"),
                            validator: (v) => v == null ? "Sports Category wajib dipilih" : null,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Activity Category
                        _rowField(
                          label: "Activity Category",
                          field: DropdownButtonFormField<String>(
                            value: _selectedActivityCategory,
                            items: _activityOptions
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedActivityCategory = v),
                            decoration: _pillDecoration("---------"),
                            validator: (v) => v == null ? "Activity Category wajib dipilih" : null,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Capacity
                        _rowField(
                          label: "Capacity",
                          field: TextFormField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            decoration: _pillDecoration("0"),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return "Capacity wajib diisi";
                              final n = int.tryParse(v.trim());
                              if (n == null) return "Capacity harus angka";
                              if (n <= 0) return "Capacity harus > 0";
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Fee + Paid checkbox (mirip HTML)
                        _rowField(
                          label: "Fee",
                          field: Row(
                            children: [
                              SizedBox(
                                width: 180,
                                child: TextFormField(
                                  controller: _feeController,
                                  keyboardType: TextInputType.number,
                                  enabled: _isPaid,
                                  decoration: _pillDecoration("", disabledLook: !_isPaid),
                                  validator: (v) {
                                    if (!_isPaid) return null;
                                    if (v == null || v.trim().isEmpty) return "Isi fee atau matiin Paid";
                                    final n = int.tryParse(v.trim());
                                    if (n == null) return "Fee harus angka";
                                    if (n < 0) return "Fee tidak boleh negatif";
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isPaid,
                                    activeColor: _btnOrange,
                                    onChanged: (val) {
                                      setState(() {
                                        _isPaid = val ?? false;
                                        if (!_isPaid) _feeController.text = "";
                                      });
                                    },
                                  ),
                                  const Text(
                                    "Paid",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Submit button: ngikut Book Event (EventDetailPage)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

                              if (_startTime == null ) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Start & End time wajib diisi.")),
                                );
                                return;
                              }
                              if (_endTime!.isBefore(_startTime!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("End time harus setelah start time.")),
                                );
                                return;
                              }

                              final payload = <String, dynamic>{
                                "name": _nameController.text.trim(),
                                "description": _descController.text.trim(),
                                "thumbnail": _thumbnailController.text.trim(),
                                "location": _locationController.text.trim(),
                                "address": _addressController.text.trim(),
                                "start_time": _startTime!.toIso8601String(),
                                "end_time": _endTime!.toIso8601String(),
                                "sports_category": _selectedSportsCategory,
                                "activity_category": _selectedActivityCategory,
                                "capacity": int.parse(_capacityController.text.trim()),
                                "fee": _isPaid ? _feeController.text.trim() : "",
                              };

                              try {
                                final response = await request.postJson(
                                  "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/event/create-flutter/",
                                  jsonEncode(payload),
                                );

                                if (!context.mounted) return;

                                if (response is Map && response["status"] == "success") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Event Created Successfully!")),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  final msg = (response is Map && response["message"] != null)
                                      ? response["message"].toString()
                                      : "Failed to create event.";
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Failed: $msg")),
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error Server: $e")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _btnOrange,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Save Event →",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
