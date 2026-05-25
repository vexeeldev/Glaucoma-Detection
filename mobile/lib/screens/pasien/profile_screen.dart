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
  bool _isLoading = true;

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _nikController;
  late TextEditingController _usernameController;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _religionController;
  late TextEditingController _nationalityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactPhoneController;
  late TextEditingController _emergencyContactRelationController;
  late TextEditingController _currentMedicationsController;
  late TextEditingController _insuranceProviderController;
  late TextEditingController _insuranceNumberController;

  // Medical data controllers
  late TextEditingController _bloodTypeController;
  late TextEditingController _medicalHistoryController;
  late TextEditingController _allergiesController;

  // Selection values
  String _selectedGender = 'male';
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadProfile();

    final user = authProvider.currentUser;
    if (user != null) {
      _initializeControllers(user);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers(UserModel user) {
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phoneNumber ?? '');
    _addressController = TextEditingController(text: user.address ?? '');
    _nikController = TextEditingController(text: user.nik ?? '');
    _usernameController = TextEditingController(text: user.username ?? '');
    _cityController = TextEditingController(text: user.city ?? '');
    _provinceController = TextEditingController(text: user.province ?? '');
    _religionController = TextEditingController(text: user.religion ?? '');
    _nationalityController = TextEditingController(text: user.nationality ?? '');
    _postalCodeController = TextEditingController(text: user.postalCode ?? '');
    _emergencyContactNameController = TextEditingController(text: user.emergencyContactName ?? '');
    _emergencyContactPhoneController = TextEditingController(text: user.emergencyContactPhone ?? '');
    _emergencyContactRelationController = TextEditingController(text: user.emergencyContactRelation ?? '');
    _currentMedicationsController = TextEditingController(text: user.currentMedications ?? '');
    _insuranceProviderController = TextEditingController(text: user.insuranceProvider ?? '');
    _insuranceNumberController = TextEditingController(text: user.insuranceNumber ?? '');

    _bloodTypeController = TextEditingController(text: user.bloodType ?? '');
    _medicalHistoryController = TextEditingController(text: user.medicalHistory ?? '');
    _allergiesController = TextEditingController(text: user.allergies ?? '');

    _selectedGender = user.gender ?? 'male';
    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      _selectedDateOfBirth = DateTime.tryParse(user.dateOfBirth!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nikController.dispose();
    _usernameController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _religionController.dispose();
    _nationalityController.dispose();
    _postalCodeController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationController.dispose();
    _currentMedicationsController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    _bloodTypeController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
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
      nik: _nikController.text.isEmpty ? null : _nikController.text,
      username: _usernameController.text.isEmpty ? null : _usernameController.text,
      dateOfBirth: _selectedDateOfBirth?.toIso8601String().split('T').first,
      gender: _selectedGender,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      province: _provinceController.text.isEmpty ? null : _provinceController.text,
      religion: _religionController.text.isEmpty ? null : _religionController.text,
      nationality: _nationalityController.text.isEmpty ? null : _nationalityController.text,
      postalCode: _postalCodeController.text.isEmpty ? null : _postalCodeController.text,
      emergencyContactName: _emergencyContactNameController.text.isEmpty ? null : _emergencyContactNameController.text,
      emergencyContactPhone: _emergencyContactPhoneController.text.isEmpty ? null : _emergencyContactPhoneController.text,
      emergencyContactRelation: _emergencyContactRelationController.text.isEmpty ? null : _emergencyContactRelationController.text,
      currentMedications: _currentMedicationsController.text.isEmpty ? null : _currentMedicationsController.text,
      insuranceProvider: _insuranceProviderController.text.isEmpty ? null : _insuranceProviderController.text,
      insuranceNumber: _insuranceNumberController.text.isEmpty ? null : _insuranceNumberController.text,
      bloodType: _bloodTypeController.text.isEmpty ? null : _bloodTypeController.text,
      medicalHistory: _medicalHistoryController.text.isEmpty ? null : _medicalHistoryController.text,
      allergies: _allergiesController.text.isEmpty ? null : _allergiesController.text,
    );

    final success = await authProvider.updateProfile(updatedUser);

    if (mounted) {
      if (success) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.logout();
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
    final user = Provider.of<AuthProvider>(context).currentUser;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat profil',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
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
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildAddressSection(),
              const SizedBox(height: 24),
              _buildEmergencyContactSection(),
              const SizedBox(height: 24),
              _buildMedicalInfoSection(),
              const SizedBox(height: 24),
              _buildInsuranceSection(),
              if (!_isEditing) ...[
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF4A90E2).withValues(alpha: 0.1),
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
        Text(
          user.email,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, size: 20, color: Color(0xFF4A90E2)),
            const SizedBox(width: 8),
            Text(
              'Data Pribadi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Nama Lengkap',
          controller: _nameController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Username',
          controller: _usernameController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'NIK',
          controller: _nikController,
          enabled: _isEditing,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Nomor HP',
          controller: _phoneController,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildGenderField(),
        const SizedBox(height: 12),
        _buildDateOfBirthField(),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Agama',
          controller: _religionController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Kewarganegaraan',
          controller: _nationalityController,
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 20, color: Color(0xFF4A90E2)),
            const SizedBox(width: 8),
            Text(
              'Alamat',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Alamat',
          controller: _addressController,
          enabled: _isEditing,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Kota',
          controller: _cityController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Provinsi',
          controller: _provinceController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Kode Pos',
          controller: _postalCodeController,
          enabled: _isEditing,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildEmergencyContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emergency, size: 20, color: Color(0xFF4A90E2)),
            const SizedBox(width: 8),
            Text(
              'Kontak Darurat',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Nama Kontak Darurat',
          controller: _emergencyContactNameController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'No HP Kontak Darurat',
          controller: _emergencyContactPhoneController,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Hubungan',
          controller: _emergencyContactRelationController,
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildMedicalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.health_and_safety, size: 20, color: Color(0xFF4A90E2)),
            const SizedBox(width: 8),
            Text(
              'Data Medis',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Golongan Darah',
          controller: _bloodTypeController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Riwayat Penyakit',
          controller: _medicalHistoryController,
          enabled: _isEditing,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Obat yang Dikonsumsi',
          controller: _currentMedicationsController,
          enabled: _isEditing,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Alergi',
          controller: _allergiesController,
          enabled: _isEditing,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildInsuranceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.health_and_safety, size: 20, color: Color(0xFF4A90E2)),
            const SizedBox(width: 8),
            Text(
              'Data Asuransi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Provider Asuransi',
          controller: _insuranceProviderController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Nomor Asuransi',
          controller: _insuranceNumberController,
          enabled: _isEditing,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    if (!_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jenis Kelamin',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _selectedGender == 'male' ? 'Laki-laki' : 'Perempuan',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'male',
              label: Text('Laki-laki'),
              icon: Icon(Icons.male),
            ),
            ButtonSegment(
              value: 'female',
              label: Text('Perempuan'),
              icon: Icon(Icons.female),
            ),
          ],
          selected: {_selectedGender},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _selectedGender = newSelection.first;
            });
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF4A90E2).withValues(alpha: 0.1);
                }
                return Colors.transparent;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    if (!_isEditing) {
      String value = '';
      if (_selectedDateOfBirth != null) {
        value = '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}';
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanggal Lahir',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.isEmpty ? '-' : value,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Lahir',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _selectDateOfBirth,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF4A90E2)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateOfBirth != null
                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                        : 'Pilih tanggal lahir',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _selectedDateOfBirth != null ? Colors.black : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
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
    );
  }
}