import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Step management
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Controllers untuk field wajib
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  // Controllers untuk field tambahan
  final _nikController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _currentMedicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  final _religionController = TextEditingController();
  final _nationalityController = TextEditingController();

  // Selection values
  String _selectedGender = 'male';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _nikController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationController.dispose();
    _bloodTypeController.dispose();
    _medicalHistoryController.dispose();
    _currentMedicationsController.dispose();
    _allergiesController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    _religionController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui syarat dan ketentuan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: 'patient',
      phoneNumber: _phoneController.text.trim(),
      nik: _nikController.text.trim(),
      username: _usernameController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
      gender: _selectedGender,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      province: _provinceController.text.trim(),
      religion: _religionController.text.trim(),
      nationality: _nationalityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      emergencyContactName: _emergencyContactNameController.text.trim(),
      emergencyContactPhone: _emergencyContactPhoneController.text.trim(),
      emergencyContactRelation: _emergencyContactRelationController.text.trim(),
      bloodType: _bloodTypeController.text.trim(),
      medicalHistory: _medicalHistoryController.text.trim(),
      currentMedications: _currentMedicationsController.text.trim(),
      allergies: _allergiesController.text.trim(),
      insuranceProvider: _insuranceProviderController.text.trim(),
      insuranceNumber: _insuranceNumberController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi gagal. Email atau username mungkin sudah terdaftar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  bool _validateCurrentStep() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      return true;
    }
    return false;
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        if (_currentStep < _totalSteps - 1) {
          _currentStep++;
        }
      });
    }
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Akun',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator - CENTERED
            _buildStepIndicator(),
            const Divider(height: 0, thickness: 1),
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) _buildAccountInfoStep(),
                      if (_currentStep == 1) _buildPersonalInfoStep(),
                      if (_currentStep == 2) _buildMedicalInfoStep(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_totalSteps, (index) {
          final isActive = _currentStep == index;
          final isCompleted = _currentStep > index;
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle indicator
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive || isCompleted
                          ? const Color(0xFF4A90E2)
                          : Colors.grey[300],
                      border: isActive
                          ? Border.all(color: const Color(0xFF4A90E2), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                color: isActive || isCompleted
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    index == 0 ? 'Akun' : (index == 1 ? 'Pribadi' : 'Medis'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? const Color(0xFF4A90E2)
                          : isCompleted
                              ? const Color(0xFF4A90E2).withValues(alpha: 0.7)
                              : Colors.grey[500],
                    ),
                  ),
                ],
              ),
              // Connecting line (except for last item)
              if (index != _totalSteps - 1)
                Container(
                  width: 50,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: isCompleted
                      ? const Color(0xFF4A90E2)
                      : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    ),
  );
}

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                  side: const BorderSide(color: Color(0xFF4A90E2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Kembali',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: (_currentStep == _totalSteps - 1)
                  ? (_isLoading ? null : _handleRegister)
                  : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const LoadingWidget()
                  : Text(
                      (_currentStep == _totalSteps - 1) ? 'Daftar' : 'Berikutnya',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Akun',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lengkapi data akun Anda',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _nameController,
          label: 'Nama Lengkap',
          icon: Icons.person_outline,
          isRequired: true,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Nama lengkap harus diisi';
            if (value.length < 3) return 'Nama minimal 3 karakter';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Email harus diisi';
            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email tidak valid';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _usernameController,
          label: 'Username',
          icon: Icons.account_circle_outlined,
          isRequired: true,
          hintText: 'contoh: johndoe123',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Username harus diisi';
            if (value.length < 3) return 'Username minimal 3 karakter';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Nomor HP',
          icon: Icons.phone_outlined,
          isRequired: true,
          keyboardType: TextInputType.phone,
          hintText: '081234567890',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Nomor HP harus diisi';
            if (value.length < 10) return 'Nomor HP minimal 10 digit';
            if (value.length > 13) return 'Nomor HP maksimal 13 digit';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordFields(),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Pribadi',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lengkapi data pribadi Anda',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        // Gender field - CENTERED
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: _buildGenderField(),
          ),
        ),
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nikController,
          label: 'NIK',
          icon: Icons.numbers_outlined,
          keyboardType: TextInputType.number,
          isRequired: true,
          hintText: '3524000011112222',
          validator: (value) {
            if (value == null || value.isEmpty) return 'NIK harus diisi';
            if (value.length != 16) return 'NIK harus 16 digit';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Alamat',
          icon: Icons.location_on_outlined,
          isRequired: true,
          maxLines: 2,
          hintText: 'Jl. Raya Lamongan No. 123',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Alamat harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _cityController,
          label: 'Kota',
          icon: Icons.location_city,
          isRequired: true,
          hintText: 'Lamongan',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Kota harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _provinceController,
          label: 'Provinsi',
          icon: Icons.map,
          isRequired: true,
          hintText: 'Jawa Timur',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Provinsi harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _postalCodeController,
          label: 'Kode Pos',
          icon: Icons.local_post_office,
          keyboardType: TextInputType.number,
          isRequired: true,
          hintText: '62211',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Kode pos harus diisi';
            if (value.length < 5) return 'Kode pos minimal 5 digit';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _religionController,
          label: 'Agama',
          icon: Icons.church_outlined,
          isRequired: true,
          hintText: 'Islam',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Agama harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nationalityController,
          label: 'Kewarganegaraan',
          icon: Icons.flag_outlined,
          isRequired: true,
          hintText: 'Indonesia',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Kewarganegaraan harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildEmergencyContactSection(),
      ],
    );
  }

  Widget _buildMedicalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Medis & Asuransi',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lengkapi data medis untuk layanan terbaik',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _bloodTypeController,
          label: 'Golongan Darah',
          icon: Icons.bloodtype,
          isRequired: true,
          hintText: 'A / B / O / AB',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Golongan darah harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _medicalHistoryController,
          label: 'Riwayat Penyakit',
          icon: Icons.health_and_safety,
          isRequired: true,
          maxLines: 2,
          hintText: 'Tulis riwayat penyakit Anda',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Riwayat penyakit harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _currentMedicationsController,
          label: 'Obat yang Dikonsumsi Saat Ini',
          icon: Icons.medication,
          isRequired: true,
          hintText: 'Contoh: Vitamin C, Amlodipine',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Data obat harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _allergiesController,
          label: 'Alergi',
          icon: Icons.warning,
          isRequired: true,
          hintText: 'Contoh: Debu, Udang, Penicillin',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Data alergi harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _insuranceProviderController,
          label: 'Provider Asuransi',
          icon: Icons.health_and_safety,
          isRequired: true,
          hintText: 'BPJS Kesehatan / Swasta',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Provider asuransi harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _insuranceNumberController,
          label: 'Nomor Asuransi',
          icon: Icons.numbers,
          keyboardType: TextInputType.number,
          isRequired: true,
          hintText: '000123456789',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Nomor asuransi harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildTermsAndConditions(),
      ],
    );
  }

  Widget _buildEmergencyContactSection() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Kontak Darurat (Wajib)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A90E2),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _emergencyContactNameController,
          label: 'Nama Kontak Darurat',
          icon: Icons.contact_emergency,
          isRequired: true,
          hintText: 'Nama keluarga/kerabat',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Nama kontak darurat harus diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyContactPhoneController,
          label: 'No HP Kontak Darurat',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          isRequired: true,
          hintText: '08987654321',
          validator: (value) {
            if (value == null || value.isEmpty) return 'No HP kontak darurat harus diisi';
            if (value.length < 10) return 'Nomor HP minimal 10 digit';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyContactRelationController,
          label: 'Hubungan',
          icon: Icons.family_restroom,
          isRequired: true,
          hintText: 'Orang Tua / Saudara / Suami / Istri',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Hubungan harus diisi';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Jenis Kelamin *',
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Lahir *',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDateOfBirth,
          child: AbsorbPointer(
            child: TextFormField(
              controller: _dateOfBirthController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Pilih tanggal lahir',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Tanggal lahir harus diisi';
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isRequired: true,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password harus diisi';
            if (value.length < 6) return 'Password minimal 6 karakter';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Konfirmasi Password',
          icon: Icons.lock_outline,
          isRequired: true,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Konfirmasi password harus diisi';
            if (value != _passwordController.text) return 'Password tidak cocok';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: const Color(0xFF4A90E2),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            child: Text(
              'Saya menyetujui Syarat dan Ketentuan serta Kebijakan Privasi',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? hintText,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: hintText,
      ),
      validator: validator ??
          (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return '$label harus diisi';
            }
            return null;
          },
    );
  }
}