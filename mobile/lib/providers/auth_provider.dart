import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyPatientId = 'patient_id'; // ✅ Tambahkan ini
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyIsLoggedIn = 'is_logged_in';

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDokter => _currentUser?.role == 'dokter' || _currentUser?.role == 'doctor';
  bool get isPasien => _currentUser?.role == 'pasien' || _currentUser?.role == 'patient';

  Future<bool> checkAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final token = await _apiService.getToken();

      if (isLoggedIn && token != null && token.isNotEmpty) {
        debugPrint('🔑 Auto login - token found: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
        final success = await loadProfile();
        if (success && _currentUser != null) {
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          debugPrint('⚠️ Auto login failed - profile load unsuccessful');
          await logout();
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Check auto login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiService.loginEndpoint,
        {'email': email, 'password': password},
      );

      debugPrint('📥 Login response: $response');

      if (response['success'] == true || response['status'] == 'success') {
        final data = response['data'];
        final userData = data['user'];
        final patientData = userData['patient'];
        final token = data['token'];

        if (token == null || token.isEmpty) {
          debugPrint('❌ ERROR: Token is null or empty!');
          _isLoading = false;
          notifyListeners();
          return false;
        }

        debugPrint('🔑 Token received: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');

        await _apiService.saveToken(token);

        // ✅ AMBIL PATIENT ID yang benar
        final userId = userData['id'].toString();
        final patientId = patientData?['id']?.toString() ?? userId;
        
        debugPrint('🔑 User ID: $userId');
        debugPrint('🔑 Patient ID (from patient table): $patientId');

        await _saveUserDataToPrefs(userData, token, patientId);

        _currentUser = UserModel(
          id: patientId, // ✅ Gunakan PATIENT ID, bukan USER ID!
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          password: '',
          role: _mapRole(userData['role'] ?? 'patient'),
          phoneNumber: userData['phone'],
          address: patientData?['address'] ?? userData['address'],
          bloodType: patientData?['blood_type'],
          medicalHistory: patientData?['medical_history'],
          allergies: patientData?['allergies'],
          insuranceName: patientData?['insurance_provider'],
          insurancePolicyNumber: patientData?['insurance_number'],
          nik: userData['nik'],
          username: userData['username'],
          dateOfBirth: patientData?['date_of_birth'] ?? userData['date_of_birth'],
          gender: patientData?['gender'] ?? userData['gender'],
          city: patientData?['city'] ?? userData['city'],
          province: patientData?['province'] ?? userData['province'],
          religion: userData['religion'],
          nationality: userData['nationality'],
          postalCode: patientData?['postal_code'],
          emergencyContactName: patientData?['emergency_contact_name'],
          emergencyContactPhone: patientData?['emergency_contact_phone'],
          emergencyContactRelation: patientData?['emergency_contact_relation'],
          currentMedications: patientData?['current_medications'],
          insuranceProvider: patientData?['insurance_provider'],
          insuranceNumber: patientData?['insurance_number'],
        );

        debugPrint('✅ Login successful: ${_currentUser!.name}');
        debugPrint('   Patient ID (will be sent to API): ${_currentUser!.id}');
        debugPrint('   Blood Type: ${_currentUser!.bloodType}');
        debugPrint('   Insurance Provider: ${_currentUser!.insuranceProvider}');

        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = response['message'] ?? 'Login gagal';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveUserDataToPrefs(Map<String, dynamic> userData, String token, String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userData['id'].toString());
    await prefs.setString(_keyPatientId, patientId); // ✅ Simpan patient_id
    await prefs.setString(_keyUserName, userData['name'] ?? '');
    await prefs.setString(_keyUserEmail, userData['email'] ?? '');
    await prefs.setString(_keyUserRole, userData['role'] ?? 'patient');
    await prefs.setString(_keyUserPhone, userData['phone'] ?? '');
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<bool> loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      if (!isLoggedIn) return false;

      final patientId = prefs.getString(_keyPatientId); // ✅ Ambil patient_id
      final userName = prefs.getString(_keyUserName);
      final userEmail = prefs.getString(_keyUserEmail);
      final userRole = prefs.getString(_keyUserRole);
      final userPhone = prefs.getString(_keyUserPhone);

      if (patientId != null && userName != null) {
        _currentUser = UserModel(
          id: patientId, // ✅ Gunakan patient_id
          name: userName,
          email: userEmail ?? '',
          password: '',
          role: _mapRole(userRole ?? 'patient'),
          phoneNumber: userPhone,
          address: null,
          bloodType: null,
          medicalHistory: null,
          allergies: null,
          insuranceName: null,
          insurancePolicyNumber: null,
          nik: null,
          username: null,
          dateOfBirth: null,
          gender: null,
          city: null,
          province: null,
          religion: null,
          nationality: null,
          postalCode: null,
          emergencyContactName: null,
          emergencyContactPhone: null,
          emergencyContactRelation: null,
          currentMedications: null,
          insuranceProvider: null,
          insuranceNumber: null,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Load user from prefs error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
    String? nik,
    String? username,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? province,
    String? religion,
    String? nationality,
    String? postalCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? bloodType,
    String? medicalHistory,
    String? currentMedications,
    String? allergies,
    String? insuranceProvider,
    String? insuranceNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };

      if (phoneNumber != null && phoneNumber.isNotEmpty) requestData['phone'] = phoneNumber;
      if (username != null && username.isNotEmpty) requestData['username'] = username;
      if (gender != null && gender.isNotEmpty) requestData['gender'] = gender;
      if (nik != null && nik.isNotEmpty) requestData['nik'] = nik;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) requestData['date_of_birth'] = dateOfBirth;
      if (address != null && address.isNotEmpty) requestData['address'] = address;
      if (city != null && city.isNotEmpty) requestData['city'] = city;
      if (province != null && province.isNotEmpty) requestData['province'] = province;
      if (religion != null && religion.isNotEmpty) requestData['religion'] = religion;
      if (nationality != null && nationality.isNotEmpty) requestData['nationality'] = nationality;
      if (postalCode != null && postalCode.isNotEmpty) requestData['postal_code'] = postalCode;
      if (emergencyContactName != null && emergencyContactName.isNotEmpty) requestData['emergency_contact_name'] = emergencyContactName;
      if (emergencyContactPhone != null && emergencyContactPhone.isNotEmpty) requestData['emergency_contact_phone'] = emergencyContactPhone;
      if (emergencyContactRelation != null && emergencyContactRelation.isNotEmpty) requestData['emergency_contact_relation'] = emergencyContactRelation;
      if (bloodType != null && bloodType.isNotEmpty) requestData['blood_type'] = bloodType;
      if (medicalHistory != null && medicalHistory.isNotEmpty) requestData['medical_history'] = medicalHistory;
      if (currentMedications != null && currentMedications.isNotEmpty) requestData['current_medications'] = currentMedications;
      if (allergies != null && allergies.isNotEmpty) requestData['allergies'] = allergies;
      if (insuranceProvider != null && insuranceProvider.isNotEmpty) requestData['insurance_provider'] = insuranceProvider;
      if (insuranceNumber != null && insuranceNumber.isNotEmpty) requestData['insurance_number'] = insuranceNumber;

      debugPrint('📝 Register request: $requestData');

      final response = await _apiService.post(
        ApiService.registerEndpoint,
        requestData,
      );

      debugPrint('📥 Register response: $response');

      if (response['success'] == true || response['status'] == 'success') {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = response['message'] ?? 'Registrasi gagal';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Register error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/api/mobile/change-password',
        {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response['success'] == true || response['status'] == 'success') {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response['message'] ?? 'Ganti password gagal';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Change password error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post(ApiService.logoutEndpoint, {});
      debugPrint('Logout API called');
    } catch (e) {
      debugPrint('Logout API error (ignored): $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyPatientId); // ✅ Hapus patient_id juga
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUserPhone);
    await prefs.setBool(_keyIsLoggedIn, false);

    await _apiService.clearToken();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();

    debugPrint('Logout successful - all data cleared');
  }

  Future<bool> loadProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _apiService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No token available, cannot load profile');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      debugPrint('🔑 Using token for profile: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');

      final response = await _apiService.get(ApiService.patientProfile);
      debugPrint('📥 Load profile response: $response');

      if (response['status'] == 'success') {
        final data = response['data'];
        final patientData = data['patient'];

        debugPrint('Patient Data - Blood Type: ${patientData?['blood_type']}');
        debugPrint('Patient Data - Medical History: ${patientData?['medical_history']}');

        // ✅ GUNAKAN PATIENT ID, BUKAN USER ID
        final userId = data['id'].toString();
        final patientId = patientData?['id']?.toString() ?? userId;

        debugPrint('🔑 User ID from profile: $userId');
        debugPrint('🔑 Patient ID from profile: $patientId');

        _currentUser = UserModel(
          id: patientId, // ✅ Patient ID!
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          password: '',
          role: _mapRole(data['role'] ?? 'patient'),
          phoneNumber: data['phone'],
          address: patientData?['address'] ?? data['address'],
          bloodType: patientData?['blood_type'],
          medicalHistory: patientData?['medical_history'],
          allergies: patientData?['allergies'],
          insuranceName: patientData?['insurance_provider'],
          insurancePolicyNumber: patientData?['insurance_number'],
          nik: data['nik'],
          username: data['username'],
          dateOfBirth: patientData?['date_of_birth'] ?? data['date_of_birth'],
          gender: patientData?['gender'] ?? data['gender'],
          city: patientData?['city'] ?? data['city'],
          province: patientData?['province'] ?? data['province'],
          religion: data['religion'],
          nationality: data['nationality'],
          postalCode: patientData?['postal_code'],
          emergencyContactName: patientData?['emergency_contact_name'],
          emergencyContactPhone: patientData?['emergency_contact_phone'],
          emergencyContactRelation: patientData?['emergency_contact_relation'],
          currentMedications: patientData?['current_medications'],
          insuranceProvider: patientData?['insurance_provider'],
          insuranceNumber: patientData?['insurance_number'],
        );

        debugPrint('✅ Profile loaded: ${_currentUser!.name}');
        debugPrint('   Patient ID: ${_currentUser!.id}'); // Ini harusnya ID dari tabel patients
        debugPrint('   Blood Type: ${_currentUser!.bloodType}');

        await _updatePrefsFromCurrentUser();

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _updatePrefsFromCurrentUser() async {
    if (_currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPatientId, _currentUser!.id); // ✅ Simpan patient_id
    await prefs.setString(_keyUserName, _currentUser!.name);
    await prefs.setString(_keyUserEmail, _currentUser!.email);
    await prefs.setString(_keyUserRole, _currentUser!.role);
    await prefs.setString(_keyUserPhone, _currentUser!.phoneNumber ?? '');
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      final Map<String, dynamic> requestData = {
        'name': updatedUser.name,
        'phone': updatedUser.phoneNumber,
        'nik': updatedUser.nik,
        'username': updatedUser.username,
        'date_of_birth': updatedUser.dateOfBirth,
        'gender': updatedUser.gender,
        'address': updatedUser.address,
        'city': updatedUser.city,
        'province': updatedUser.province,
        'religion': updatedUser.religion,
        'nationality': updatedUser.nationality,
        'postal_code': updatedUser.postalCode,
        'emergency_contact_name': updatedUser.emergencyContactName,
        'emergency_contact_phone': updatedUser.emergencyContactPhone,
        'emergency_contact_relation': updatedUser.emergencyContactRelation,
        'blood_type': updatedUser.bloodType,
        'medical_history': updatedUser.medicalHistory,
        'current_medications': updatedUser.currentMedications,
        'allergies': updatedUser.allergies,
        'insurance_provider': updatedUser.insuranceProvider,
        'insurance_number': updatedUser.insuranceNumber,
      };

      requestData.removeWhere((key, value) => 
        value == null || value.toString().isEmpty
      );

      debugPrint('📤 Update profile request: $requestData');

      final response = await _apiService.put(
        ApiService.patientProfile,
        requestData,
      );

      debugPrint('📥 Update profile response: $response');

      if (response['success'] == true || response['status'] == 'success') {
        final responseData = response['data'];
        if (responseData != null) {
          final patientData = responseData['patient'];
          final patientId = patientData?['id']?.toString() ?? responseData['id'].toString();
          
          _currentUser = UserModel(
            id: patientId,
            name: responseData['name'] ?? _currentUser!.name,
            email: responseData['email'] ?? _currentUser!.email,
            password: '',
            role: _mapRole(responseData['role'] ?? _currentUser!.role),
            phoneNumber: responseData['phone'] ?? _currentUser!.phoneNumber,
            address: patientData?['address'] ?? responseData['address'],
            bloodType: patientData?['blood_type'] ?? _currentUser!.bloodType,
            medicalHistory: patientData?['medical_history'] ?? _currentUser!.medicalHistory,
            allergies: patientData?['allergies'] ?? _currentUser!.allergies,
            insuranceName: patientData?['insurance_provider'] ?? _currentUser!.insuranceName,
            insurancePolicyNumber: patientData?['insurance_number'] ?? _currentUser!.insurancePolicyNumber,
            nik: responseData['nik'] ?? _currentUser!.nik,
            username: responseData['username'] ?? _currentUser!.username,
            dateOfBirth: patientData?['date_of_birth'] ?? responseData['date_of_birth'],
            gender: patientData?['gender'] ?? responseData['gender'],
            city: patientData?['city'] ?? responseData['city'],
            province: patientData?['province'] ?? responseData['province'],
            religion: responseData['religion'] ?? _currentUser!.religion,
            nationality: responseData['nationality'] ?? _currentUser!.nationality,
            postalCode: patientData?['postal_code'] ?? _currentUser!.postalCode,
            emergencyContactName: patientData?['emergency_contact_name'] ?? _currentUser!.emergencyContactName,
            emergencyContactPhone: patientData?['emergency_contact_phone'] ?? _currentUser!.emergencyContactPhone,
            emergencyContactRelation: patientData?['emergency_contact_relation'] ?? _currentUser!.emergencyContactRelation,
            currentMedications: patientData?['current_medications'] ?? _currentUser!.currentMedications,
            insuranceProvider: patientData?['insurance_provider'] ?? _currentUser!.insuranceProvider,
            insuranceNumber: patientData?['insurance_number'] ?? _currentUser!.insuranceNumber,
          );
          
          await _updatePrefsFromCurrentUser();
        } else {
          await loadProfile();
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      final errorMessage = response['message'] ?? 'Gagal memperbarui profil';
      debugPrint('❌ Update failed: $errorMessage');
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfileField(String field, dynamic value) async {
    try {
      final response = await _apiService.put(
        ApiService.patientProfile,
        {field: value},
      );

      if (response['status'] == 'success' || response['success'] == true) {
        await loadProfile();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating profile field: $e');
      return false;
    }
  }

  String _mapRole(String role) {
    final lowerRole = role.toLowerCase();
    if (lowerRole == 'doctor' || lowerRole == 'dokter') {
      return 'dokter';
    }
    if (lowerRole == 'patient' || lowerRole == 'pasien') {
      return 'pasien';
    }
    return lowerRole;
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}