import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportnet/screens/homepage.dart';
import 'package:sportnet/widgets/custom_textfield.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  String _selectedRole = 'participant'; 
  
  // Controllers
  final _nameController = TextEditingController();
  final _locationEmailController = TextEditingController(); 
  final _dateController = TextEditingController(); 
  
  DateTime? _selectedDate;
  bool _isLoading = false;

  String? _nameError;
  String? _secInfoError; 
  String? _dateError;

  @override
  void dispose() {
    _nameController.dispose();
    _locationEmailController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF7F50),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        _dateError = null;
      });
    }
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      if (_nameController.text.trim().isEmpty) {
        _nameError = _selectedRole == 'organizer' 
            ? "Organizer Name is required" 
            : "Full Name is required";
        isValid = false;
      } else {
        _nameError = null;
      }

      if (_locationEmailController.text.trim().isEmpty) {
        _secInfoError = _selectedRole == 'organizer' 
            ? "Contact Email is required" 
            : "Location is required";
        isValid = false;
      } else {
        _secInfoError = null;
      }

      if (_selectedRole == 'participant' && _selectedDate == null) {
        _dateError = "Birth Date is required";
        isValid = false;
      } else {
        _dateError = null;
      }
    });
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    String nameLabel = _selectedRole == 'organizer' ? "Organizer Name" : "Full Name";
    String secLabel = _selectedRole == 'organizer' ? "Contact Email" : "Location (City)";
    String secHint  = _selectedRole == 'organizer' ? "e.g. contact@community.com" : "e.g. Jakarta, Indonesia";
    IconData secIcon = _selectedRole == 'organizer' ? Icons.email : Icons.location_city;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 70),

              const Text(
                "Create Profile",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 10),
              
              const Text(
                "Complete your details to get started.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Choose your role",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFF7F50), width: 1.5),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7F50).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF7F50)),
                    items: [
                      DropdownMenuItem(
                        value: 'participant',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Color(0xFFFF7F50), size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Participant",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'organizer',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.groups, color: Color(0xFFFF7F50), size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Event Organizer",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                        // Reset semua input & error saat ganti role
                        _nameController.clear();
                        _locationEmailController.clear();
                        _dateController.clear();
                        _selectedDate = null;
                        
                        _nameError = null;
                        _secInfoError = null;
                        _dateError = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              CustomTextField(
                controller: _nameController,
                label: nameLabel,
                hintText: "Enter name",
                icon: _selectedRole == 'organizer' ? Icons.groups : Icons.person,
                errorText: _nameError, 
                onChanged: (val) {
                   if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _locationEmailController,
                label: secLabel,
                hintText: secHint,
                icon: secIcon,
                keyboardType: _selectedRole == 'organizer' ? TextInputType.emailAddress : TextInputType.text,
                errorText: _secInfoError, 
                onChanged: (val) {
                   if (_secInfoError != null) setState(() => _secInfoError = null);
                },
              ),
              const SizedBox(height: 20),

              if (_selectedRole == 'participant') ...[
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _dateController,
                      label: "Birth Date",
                      hintText: "dd/mm/yyyy",
                      icon: Icons.calendar_today,
                      suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      errorText: _dateError, 
                    )
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (!_validateInputs()) {
                      return; 
                    }

                    setState(() => _isLoading = true);

                    Map<String, dynamic> data = {
                      'role': _selectedRole,
                      'about': '-',
                    };

                    if (_selectedRole == 'participant') {
                      data['full_name'] = _nameController.text;
                      data['location'] = _locationEmailController.text;
                      data['birth_date'] = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                      data['interests'] = '-';
                    } else {
                      data['organizer_name'] = _nameController.text;
                      data['contact_email'] = _locationEmailController.text;
                      data['contact_phone'] = '-';
                    }

                    try {
                      final response = await request.postJson(
                        "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/profile/api/create/",
                        jsonEncode(data),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage()),
                            (route) => false,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Welcome to SportNet!"), backgroundColor: Colors.green));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Failed"), backgroundColor: Colors.red));
                        }
                      }
                    } catch (e) {
                      if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                    shadowColor: const Color(0xFFFF7F50).withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text("Save Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}