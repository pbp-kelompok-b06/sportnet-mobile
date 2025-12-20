import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sportnet/widgets/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget{
  final Map<String, dynamic> userData;
  const EditProfilePage ({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController(); // participant
  final _contactPhoneController = TextEditingController(); // organizer
  final _contactEmailController = TextEditingController(); // organizer
  final _interestsController = TextEditingController(); // participant
  final _aboutController = TextEditingController();
  final _dateController = TextEditingController();

  String? _imageBase64;

  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    // isi data awal
    final profile = widget.userData['profile'];
    final role = widget.userData['user']['role'];

    if (role == 'participant') {
      _nameController.text = profile['full_name'] ?? "";
      _locationController.text = profile['location'] ?? "";
      _interestsController.text = profile['interests'] == '-' ? "" : (profile['interests'] ?? "");
      
      if (profile['birth_date'] != null && profile['birth_date'] != '-') {
        try {
          _selectedDate = DateTime.parse(profile['birth_date']);
          _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        } catch (e) {
          // Ignore parse error
        }
      }
    }
    else {
      // Organizer
      _nameController.text = profile['organizer_name'] ?? "";
      _contactEmailController.text = profile['contact_email'] ?? "";
      _contactPhoneController.text = profile['contact_phone'] ?? "";
    }

    _aboutController.text = profile['about'] == '-' ? "" : (profile['about'] ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _interestsController.dispose();
    _aboutController.dispose();
    _dateController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      });
    }
  }

Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  
  if (pickedFile != null) {
    final bytes = await pickedFile.readAsBytes(); // Baca sebagai bytes
    setState(() {
      _imageBase64 = base64Encode(bytes); // Konversi bytes ke string Base64
    });
  }
}

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        final role = widget.userData['user']['role'];
        _nameErrorText = role == 'participant' 
            ? "Full Name cannot be empty!" 
            : "Organizer Name cannot be empty!";
      });
      return; 
    }
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    final role = widget.userData['user']['role'];

    // Data Teks
    Map<String, dynamic> fields = {};
    if (role == 'participant') {
    fields = {
      'full_name': _nameController.text,
      'location': _locationController.text,
      'interests': _interestsController.text.isEmpty ? '-' : _interestsController.text,
      'birth_date': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
      'about': _aboutController.text.isEmpty ? '-' : _aboutController.text,

      'profile_picture_base64': _imageBase64 ?? "", 
    };
    } else {
      fields = {
        'organizer_name': _nameController.text,
        'contact_email': _contactEmailController.text,
        'contact_phone': _contactPhoneController.text,
        'about': _aboutController.text.isEmpty ? '-' : _aboutController.text,
        
        'profile_picture_base64': _imageBase64 ?? "",
      };
    }

    final String url = "https://anya-aleena-sportnet.pbp.cs.ui.ac.id/profile/api/edit/";

    try {
      final response = await request.postJson(
      url,
      jsonEncode(fields),
    );

    if (response['status'] == 'success') {
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } else {
      if (!mounted) return;
      String errorMessage = response['message'] ?? "Gagal memperbarui profil. Coba lagi.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error Jaringan/Server: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.userData['user']['role'];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // header title
            const Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7F50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Keep your profile information up to date.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Center (
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),

                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imageBase64 != null
                          ? MemoryImage(base64Decode(_imageBase64!))
                          : ((widget.userData['profile']['profile_picture'] ?? "").isNotEmpty 
                              ? NetworkImage(
                                  'https://anya-aleena-sportnet.pbp.cs.ui.ac.id${widget.userData['profile']['profile_picture']}',
                                )
                              : const AssetImage('assets/image/profile-default.png')) 
                          as ImageProvider,
                          
                      child: (_imageBase64 == null && 
                              (widget.userData['profile']['profile_picture'] ?? "").isEmpty)
                          ? const Icon(Icons.camera_alt, color: Colors.deepOrange)
                          : null,
                    ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7F50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            if (role == 'participant') ...[
              _buildLabel("Full Name"),
              CustomTextField(controller: _nameController, hintText: "Enter full name", icon: Icons.person, errorText: _nameErrorText, onChanged: (val) {

                if (_nameErrorText != null) {
                    setState(() => _nameErrorText = null);
                }
            },),
              
              const SizedBox(height: 16),
              
              _buildLabel("Location"),
              CustomTextField(controller: _locationController, hintText: "Enter city/location", icon: Icons.location_on),
              
              const SizedBox(height: 16),
              
              _buildLabel("Birth Date"),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: _dateController,
                    hintText: "Select date",
                    icon: Icons.calendar_today,
                    suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              
              _buildLabel("Interests"),
              CustomTextField(controller: _interestsController, hintText: "e.g. Running, Padel, Yoga", icon: Icons.sports_tennis),
            ] else ...[
              _buildLabel("Organizer Name"),
              CustomTextField(controller: _nameController, hintText: "Organizer / Community Name", icon: Icons.groups),
              
              const SizedBox(height: 16),

              _buildLabel("Contact Email"),
              CustomTextField(controller: _contactEmailController, hintText: "Public contact email", icon: Icons.email, keyboardType: TextInputType.emailAddress),
              
              const SizedBox(height: 16),
              
              _buildLabel("Contact Phone"),
              CustomTextField(controller: _contactPhoneController, hintText: "Public phone number", icon: Icons.phone, keyboardType: TextInputType.phone),
            ],

            const SizedBox(height: 16),
            
            _buildLabel("About"),
            CustomTextField(
              controller: _aboutController, 
              hintText: "Tell us about yourself...", 
              icon: Icons.info_outline,
              maxLines: 2,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7F50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        )
      )
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}