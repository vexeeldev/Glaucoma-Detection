import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyIsLoggedIn = 'is_logged_in';

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
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
        final patientData = userData['patient']; // <-- Data medis ada di sini!
        final token = data['token'];

        if (token == null || token.isEmpty) {
          debugPrint('❌ ERROR: Token is null or empty!');
          _isLoading = false;
          notifyListeners();
          return false;
        }

        debugPrint('🔑 Token received: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');

        await _apiService.saveToken(token);

        final savedToken = await _apiService.getToken();
        debugPrint('🔑 Token saved verification: ${savedToken?.substring(0, savedToken.length > 20 ? 20 : savedToken.length)}...');

        await _saveUserDataToPrefs(userData, token);

        _currentUser = UserModel(
          id: userData['id'].toString(),
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
        debugPrint('   Blood Type: ${_currentUser!.bloodType}');
        debugPrint('   Insurance Provider: ${_currentUser!.insuranceProvider}');

        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveUserDataToPrefs(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userData['id'].toString());
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

      final userId = prefs.getString(_keyUserId);
      final userName = prefs.getString(_keyUserName);
      final userEmail = prefs.getString(_keyUserEmail);
      final userRole = prefs.getString(_keyUserRole);
      final userPhone = prefs.getString(_keyUserPhone);

      if (userId != null && userName != null) {
        _currentUser = UserModel(
          id: userId,
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
    notifyListeners();

    try {
      final Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };

      // Field wajib
      if (phoneNumber != null && phoneNumber.isNotEmpty) requestData['phone'] = phoneNumber;
      if (username != null && username.isNotEmpty) requestData['username'] = username;
      if (gender != null && gender.isNotEmpty) requestData['gender'] = gender;

      // Field opsional
      if (nik != null && nik.isNotEmpty) requestData['nik'] = nik;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) requestData['date_of_birth'] = dateOfBirth;
      if (address != null && address.isNotEmpty) requestData['address'] = address;
      if (city != null && city.isNotEmpty) requestData['city'] = city;
      if (province != null && province.isNotEmpty) requestData['province'] = province;
      if (religion != null && religion.isNotEmpty) requestData['religion'] = religion;
      if (nationality != null && nationality.isNotEmpty) requestData['nationality'] = nationality;

      // Field tambahan
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

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Register error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
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
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Change password error: $e');
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
        final patientData = data['patient']; // <-- Data medis ada di sini!

        debugPrint('Patient Data - Blood Type: ${patientData?['blood_type']}');
        debugPrint('Patient Data - Medical History: ${patientData?['medical_history']}');
        debugPrint('Patient Data - Allergies: ${patientData?['allergies']}');
        debugPrint('Patient Data - Insurance Provider: ${patientData?['insurance_provider']}');

        _currentUser = UserModel(
          id: data['id'].toString(),
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
        debugPrint('   Blood Type: ${_currentUser!.bloodType}');
        debugPrint('   Medical History: ${_currentUser!.medicalHistory}');
        debugPrint('   Allergies: ${_currentUser!.allergies}');
        debugPrint('   Insurance Provider: ${_currentUser!.insuranceProvider}');
        debugPrint('   Insurance Number: ${_currentUser!.insuranceNumber}');

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
    await prefs.setString(_keyUserId, _currentUser!.id);
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

      requestData.removeWhere((key, value) => value == null || value.toString().isEmpty);

      debugPrint('📝 Update profile request: $requestData');

      final response = await _apiService.put(
        ApiService.patientProfile,
        requestData,
      );

      debugPrint('📥 Update profile response: $response');

      if (response['status'] == 'success') {
        await loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

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

      if (response['status'] == 'success') {
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