import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../auth/change_password_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _medicalHistoryController;
  late TextEditingController _allergiesController;
  late TextEditingController _insuranceNameController;
  late TextEditingController _insurancePolicyController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _initializeControllers(user!);
  }

  void _initializeControllers(UserModel user) {
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phoneNumber ?? '');
    _addressController = TextEditingController(text: user.address ?? '');
    _bloodTypeController = TextEditingController(text: user.bloodType ?? '');
    _medicalHistoryController = TextEditingController(text: user.medicalHistory ?? '');
    _allergiesController = TextEditingController(text: user.allergies ?? '');
    _insuranceNameController = TextEditingController(text: user.insuranceName ?? '');
    _insurancePolicyController = TextEditingController(text: user.insurancePolicyNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloodTypeController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _insuranceNameController.dispose();
    _insurancePolicyController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser!;

    final updatedUser = UserModel(
      id: currentUser.id,
      name: _nameController.text,
      email: currentUser.email,
      password: currentUser.password,
      role: currentUser.role,
      phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      bloodType: _bloodTypeController.text.isEmpty ? null : _bloodTypeController.text,
      medicalHistory: _medicalHistoryController.text.isEmpty ? null : _medicalHistoryController.text,
      allergies: _allergiesController.text.isEmpty ? null : _allergiesController.text,
      insuranceName: _insuranceNameController.text.isEmpty ? null : _insuranceNameController.text,
      insurancePolicyNumber: _insurancePolicyController.text.isEmpty ? null : _insurancePolicyController.text,
    );

    await authProvider.updateProfile(updatedUser);

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                authProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A90E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Email (non-editable)
            Text(
              user.email,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information Section
            _buildSection(
              title: 'Data Pribadi',
              icon: Icons.person_outline,
              children: [
                _buildEditableField(
                  label: 'Nama Lengkap',
                  controller: _nameController,
                  enabled: _isEditing,
                ),
                _buildEditableField(
                  label: 'Nomor HP',
                  controller: _phoneController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
                _buildEditableField(
                  label: 'Alamat',
                  controller: _addressController,
                  enabled: _isEditing,
                  maxLines: 2,
                ),
              ],
            ),

            // Medical Information Section
            _buildSection(
              title: 'Data Medis',
              icon: Icons.health_and_safety,
              children: [
                _buildEditableField(
                  label: 'Golongan Darah',
                  controller: _bloodTypeController,
                  enabled: _isEditing,
                ),
                _buildEditableField(
                  label: 'Riwayat Penyakit',
                  controller: _medicalHistoryController,
                  enabled: _isEditing,
                  maxLines: 2,
                ),
                _buildEditableField(
                  label: 'Alergi',
                  controller: _allergiesController,
                  enabled: _isEditing,
                  maxLines: 2,
                ),
              ],
            ),

            // Insurance Information Section
            _buildSection(
              title: 'Data Asuransi',
              icon: Icons.health_and_safety,
              children: [
                _buildEditableField(
                  label: 'Nama Asuransi',
                  controller: _insuranceNameController,
                  enabled: _isEditing,
                ),
                _buildEditableField(
                  label: 'Nomor Polis',
                  controller: _insurancePolicyController,
                  enabled: _isEditing,
                ),
              ],
            ),

            // Actions
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.lock_reset, color: Color(0xFF4A90E2)),
                title: const Text('Ganti Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: _logout,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF4A90E2)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: enabled ? Colors.black : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}