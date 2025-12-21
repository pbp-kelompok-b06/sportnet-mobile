import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sportnet/models/models.dart'; //

class EventFormPage extends StatefulWidget {
  final Event? event; //
  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Styling
  static const Color _btnOrange = Color(0xFFFF7F50);
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
  bool _isPaid = false;

  final List<String> _sportsOptions = ['Badminton', 'Basketball', 'Futsal', 'Soccer', 'Swimming', 'Running', 'Gym', 'Yoga', 'Tennis', 'Volleyball'];
  final List<String> _activityOptions = ['Sparring', 'Tournament', 'Fun Match', 'Training', 'Coaching'];

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    if (e != null) {
      // Inisialisasi data untuk mode EDIT
      _nameController.text = e.name;
      _descController.text = e.description;
      _thumbnailController.text = e.thumbnail;
      _locationController.text = e.location;
      _addressController.text = e.address;
      _capacityController.text = e.capacity.toString();
      _startTime = e.startTime;
      _endTime = e.endTime;
      _selectedSportsCategory = e.sportsCategory;
      _selectedActivityCategory = e.activityCategory;

      final feeNum = int.tryParse(e.fee.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      _isPaid = feeNum > 0;
      _feeController.text = _isPaid ? feeNum.toString() : "";
    }
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
    // Gunakan waktu yang sudah ada jika tersedia
    final initialDate = isStart ? (_startTime ?? now) : (_endTime ?? _startTime ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: _btnOrange)),
        child: child!,
      ),
    );
    if (date == null) return null;

    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Widget _rowField({required String label, required Widget field, bool alignTop = false}) {
    return Row(
      crossAxisAlignment: alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        Expanded(child: field),
      ],
    );
  }

  InputDecoration _pillDecoration(String hint, {bool disabledLook = false}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: disabledLook ? Colors.grey[100] : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: _btnOrange, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isEdit = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Event" : "Create Event", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _btnOrange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_bgTop, _bgBottom]),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(blurRadius: 18, color: Colors.black.withOpacity(0.08), offset: const Offset(0, 10))],
                ),
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(isEdit ? "Update Event" : "Create Event", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: _btnOrange)),
                      const SizedBox(height: 26),

                      _rowField(label: "Name", field: TextFormField(controller: _nameController, decoration: _pillDecoration("Event Name"), validator: (v) => (v == null || v.isEmpty) ? "Wajib diisi" : null)),
                      const SizedBox(height: 14),

                      _rowField(label: "Description", alignTop: true, field: TextFormField(controller: _descController, decoration: _pillDecoration("Description"), minLines: 3, maxLines: 5)),
                      const SizedBox(height: 14),

                      _rowField(label: "Thumbnail", field: TextFormField(controller: _thumbnailController, decoration: _pillDecoration("Image URL"))),
                      const SizedBox(height: 14),

                      // === BAGIAN DATE & TIME (PENTING) ===
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
                                  decoration: _pillDecoration("Start Time"),
                                  child: Text(
                                    _startTime != null ? DateFormat('dd/MM HH:mm').format(_startTime!) : "Start",
                                    style: TextStyle(color: _startTime == null ? Colors.grey[500] : Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            const Text(" – "),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final dt = await _pickDateTime(context, isStart: false);
                                  if (dt != null) setState(() => _endTime = dt);
                                },
                                child: InputDecorator(
                                  decoration: _pillDecoration("End Time"),
                                  child: Text(
                                    _endTime != null ? DateFormat('dd/MM HH:mm').format(_endTime!) : "End",
                                    style: TextStyle(color: _endTime == null ? Colors.grey[500] : Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      _rowField(label: "Location", field: TextFormField(controller: _locationController, decoration: _pillDecoration("Location"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null)),
                      const SizedBox(height: 14),

                      _rowField(label: "Address", field: TextFormField(controller: _addressController, decoration: _pillDecoration("Full Address"))),
                      const SizedBox(height: 14),

                      _rowField(
                        label: "Sports Category",
                        field: DropdownButtonFormField<String>(
                          value: _selectedSportsCategory,
                          items: _sportsOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _selectedSportsCategory = v),
                          decoration: _pillDecoration("Category"),
                        ),
                      ),
                      const SizedBox(height: 14),

                      _rowField(
                        label: "Activity Category",
                        field: DropdownButtonFormField<String>(
                          value: _selectedActivityCategory,
                          items: _activityOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _selectedActivityCategory = v),
                          decoration: _pillDecoration("Activity"),
                        ),
                      ),
                      const SizedBox(height: 14),

                      _rowField(
                        label: "Capacity",
                        field: TextFormField(controller: _capacityController, keyboardType: TextInputType.number, decoration: _pillDecoration("Max Participants")),
                      ),
                      const SizedBox(height: 14),

                      _rowField(
                        label: "Fee",
                        field: Row(
                          children: [
                            SizedBox(width: 150, child: TextFormField(controller: _feeController, enabled: _isPaid, decoration: _pillDecoration("0", disabledLook: !_isPaid))),
                            Checkbox(value: _isPaid, activeColor: _btnOrange, onChanged: (v) => setState(() { _isPaid = v!; if (!_isPaid) _feeController.clear(); })),
                            const Text("Paid", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (_startTime == null || _endTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi waktu mulai & selesai!")));
                              return;
                            }

                            final payload = {
                              "name": _nameController.text.trim(),
                              "description": _descController.text.trim(),
                              "thumbnail": _thumbnailController.text.trim(),
                              "location": _locationController.text.trim(),
                              "address": _addressController.text.trim(),
                              "start_time": _startTime!.toIso8601String(),
                              "end_time": _endTime!.toIso8601String(),
                              "sports_category": _selectedSportsCategory,
                              "activity_category": _selectedActivityCategory,
                              "capacity": int.tryParse(_capacityController.text) ?? 0,
                              "fee": _isPaid ? _feeController.text.trim() : "0",
                            };

                            final url = isEdit 
                                ? "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/event/edit-flutter/${widget.event!.id}/"
                                : "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/event/create-flutter/";

                            final response = await request.postJson(url, jsonEncode(payload));
                            if (response["status"] == "success" && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? "Event Updated!" : "Event Created!")));
                              Navigator.pop(context, true);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: _btnOrange, foregroundColor: Colors.white, shape: const StadiumBorder()),
                          child: Text(isEdit ? "Update Event" : "Save Event →", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    );
  }
}