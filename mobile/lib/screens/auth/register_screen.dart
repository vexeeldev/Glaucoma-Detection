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
  bool _showAdditionalFields = false;

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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Debug: Print semua data yang akan dikirim
      debugPrint('=' * 50);
      debugPrint('📝 REGISTER DATA:');
      debugPrint('=' * 50);
      debugPrint('  name: ${_nameController.text.trim()}');
      debugPrint('  email: ${_emailController.text.trim()}');
      debugPrint('  password: ${_passwordController.text}');
      debugPrint('  phone: ${_phoneController.text.trim()}');
      debugPrint('  username: ${_usernameController.text.trim()}');
      debugPrint('  nik: ${_nikController.text.trim()}');
      debugPrint('  date_of_birth: ${_dateOfBirthController.text.trim()}');
      debugPrint('  gender: $_selectedGender');
      debugPrint('  address: ${_addressController.text.trim()}');
      debugPrint('  city: ${_cityController.text.trim()}');
      debugPrint('  province: ${_provinceController.text.trim()}');
      debugPrint('  postal_code: ${_postalCodeController.text.trim()}');
      debugPrint('  emergency_contact_name: ${_emergencyContactNameController.text.trim()}');
      debugPrint('  emergency_contact_phone: ${_emergencyContactPhoneController.text.trim()}');
      debugPrint('  emergency_contact_relation: ${_emergencyContactRelationController.text.trim()}');
      debugPrint('  blood_type: ${_bloodTypeController.text.trim()}');
      debugPrint('  medical_history: ${_medicalHistoryController.text.trim()}');
      debugPrint('  current_medications: ${_currentMedicationsController.text.trim()}');
      debugPrint('  allergies: ${_allergiesController.text.trim()}');
      debugPrint('  insurance_provider: ${_insuranceProviderController.text.trim()}');
      debugPrint('  insurance_number: ${_insuranceNumberController.text.trim()}');
      debugPrint('  religion: ${_religionController.text.trim()}');
      debugPrint('  nationality: ${_nationalityController.text.trim()}');
      debugPrint('=' * 50);

      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: 'patient', // Default role pasien
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
        // Field tambahan
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
        debugPrint('✅ REGISTER SUCCESS!');
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
        debugPrint('❌ REGISTER FAILED!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi gagal. Email mungkin sudah terdaftar'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildRequiredFields(),
                const SizedBox(height: 16),
                _buildToggleAdditionalFields(),
                if (_showAdditionalFields) _buildAdditionalFields(),
                _buildPasswordFields(),
                const SizedBox(height: 24),
                _buildRegisterButton(),
                const SizedBox(height: 16),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.visibility,
              size: 40,
              color: Color(0xFF4A90E2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Buat Akun Baru',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Daftar untuk menggunakan EyeCare',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nama Lengkap',
          icon: Icons.person_outline,
          isRequired: true,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
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
            if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
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
          hintText: 'contoh: kabir_rabbani',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Username tidak boleh kosong';
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
            if (value == null || value.isEmpty) return 'Nomor HP tidak boleh kosong';
            if (value.length < 10) return 'Nomor HP minimal 10 digit';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildGenderField(),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildToggleAdditionalFields() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAdditionalFields = !_showAdditionalFields;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              _showAdditionalFields ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFF4A90E2),
            ),
            const SizedBox(width: 8),
            Text(
              _showAdditionalFields
                  ? 'Sembunyikan Data Lengkap'
                  : 'Isi Data Lengkap (Opsional)',
              style: GoogleFonts.poppins(
                color: const Color(0xFF4A90E2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nikController,
          label: 'NIK',
          icon: Icons.numbers_outlined,
          keyboardType: TextInputType.number,
          hintText: '3524000011112222',
        ),
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Alamat',
          icon: Icons.location_on_outlined,
          maxLines: 2,
          hintText: 'Jl. Raya Lamongan No. 123',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _cityController,
          label: 'Kota',
          icon: Icons.location_city,
          hintText: 'Lamongan',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _provinceController,
          label: 'Provinsi',
          icon: Icons.map,
          hintText: 'Jawa Timur',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _postalCodeController,
          label: 'Kode Pos',
          icon: Icons.local_post_office,
          keyboardType: TextInputType.number,
          hintText: '62211',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyContactNameController,
          label: 'Nama Kontak Darurat',
          icon: Icons.contact_emergency,
          hintText: 'Seseorang',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyContactPhoneController,
          label: 'No HP Kontak Darurat',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          hintText: '08987654321',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyContactRelationController,
          label: 'Hubungan Kontak Darurat',
          icon: Icons.family_restroom,
          hintText: 'Parent',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _bloodTypeController,
          label: 'Golongan Darah',
          icon: Icons.bloodtype,
          hintText: 'O',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _medicalHistoryController,
          label: 'Riwayat Penyakit',
          icon: Icons.health_and_safety,
          maxLines: 2,
          hintText: 'Tidak ada riwayat penyakit berat',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _currentMedicationsController,
          label: 'Obat yang Dikonsumsi Saat Ini',
          icon: Icons.medication,
          hintText: 'Vitamin C',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _allergiesController,
          label: 'Alergi',
          icon: Icons.warning,
          hintText: 'Debu',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _insuranceProviderController,
          label: 'Provider Asuransi',
          icon: Icons.health_and_safety,
          hintText: 'BPJS Kesehatan',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _insuranceNumberController,
          label: 'Nomor Asuransi',
          icon: Icons.numbers,
          keyboardType: TextInputType.number,
          hintText: '000123456789',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _religionController,
          label: 'Agama',
          icon: Icons.church_outlined,
          hintText: 'Islam',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nationalityController,
          label: 'Kewarganegaraan',
          icon: Icons.flag_outlined,
          hintText: 'Indonesia',
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDateOfBirth,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dateOfBirthController,
          decoration: InputDecoration(
            labelText: 'Tanggal Lahir',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'YYYY-MM-DD',
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
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
            if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
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
            if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong';
            if (value != _passwordController.text) return 'Password tidak cocok';
            return null;
          },
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
              return '$label tidak boleh kosong';
            }
            return null;
          },
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const LoadingWidget()
            : Text(
          'Daftar',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: Text(
            'Login',
            style: GoogleFonts.poppins(
              color: const Color(0xFF4A90E2),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}