import 'package:flutter/material.dart';

class PersonalInformationView extends StatefulWidget {
  const PersonalInformationView({super.key});

  @override
  State<PersonalInformationView> createState() =>
      _PersonalInformationViewState();
}

class _PersonalInformationViewState extends State<PersonalInformationView> {
  static const Color _background = Color(0xFFF5F6F8);
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _accent = Color(0xFF1D7A6B);
  static const Color _cardBorder = Color(0xFFE7EAF0);

  bool _isEditing = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _sportsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Saantha Sudarshana');
    _emailController = TextEditingController(text: 'SaSudarshana@email.com');
    _phoneController = TextEditingController(text: '+94 77 123 4567');
    _addressController = TextEditingController(text: 'Colombo 07, Sri Lanka');
    _sportsController = TextEditingController(text: 'Badminton, Tennis');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _sportsController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal information updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _heading,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _heading,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(
                color: _accent,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF0D2B4E),
                      child: Text(
                        'SD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: _accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _nameController.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _heading,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F7EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Verified Member',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C7A4C),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Profile Details'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: Column(
                  children: [
                    _buildField(
                      icon: Icons.person_outline_rounded,
                      label: 'Full Name',
                      controller: _nameController,
                      isEditing: _isEditing,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F3F6)),
                    _buildField(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email Address',
                      controller: _emailController,
                      isEditing: _isEditing,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F3F6)),
                    _buildField(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      controller: _phoneController,
                      isEditing: _isEditing,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F3F6)),
                    _buildField(
                      icon: Icons.location_on_outlined,
                      label: 'Address / Location',
                      controller: _addressController,
                      isEditing: _isEditing,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F3F6)),
                    _buildField(
                      icon: Icons.sports_tennis_rounded,
                      label: 'Preferred Sports',
                      controller: _sportsController,
                      isEditing: _isEditing,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _nameController.text = 'Saantha Sudarshana';
                            _emailController.text = 'SaSudarshana@email.com';
                            _phoneController.text = '+94 77 123 4567';
                            _addressController.text = 'Colombo 07, Sri Lanka';
                            _sportsController.text = 'Badminton, Tennis';
                            _isEditing = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _heading,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: _cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _heading,
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: _subtext),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11.5, color: _subtext),
                ),
                const SizedBox(height: 2),
                isEditing
                    ? TextField(
                        controller: controller,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _heading,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          border: InputBorder.none,
                        ),
                      )
                    : Text(
                        controller.text,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _heading,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}