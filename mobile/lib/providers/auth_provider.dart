import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Keys untuk SharedPreferences
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

  // Cek apakah user sudah login sebelumnya (dipanggil saat app start)
  Future<bool> checkAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final token = await _apiService.getToken();

      if (isLoggedIn && token != null && token.isNotEmpty) {
        // Coba load profile untuk verifikasi token masih valid
        final success = await loadProfile();

        if (success && _currentUser != null) {
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          // Token expired atau invalid
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

      debugPrint('Login response: $response');

      if (response['success'] == true || response['status'] == 'success') {
        final data = response['data'];
        final userData = data['user'];
        final token = data['token'];

        // Save token ke ApiService dan SharedPreferences
        await _apiService.saveToken(token);

        // Simpan data user ke SharedPreferences
        await _saveUserDataToPrefs(userData, token);

        // Convert user data ke UserModel
        _currentUser = UserModel(
          id: userData['id'].toString(),
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          password: '',
          role: _mapRole(userData['role'] ?? 'patient'),
          phoneNumber: userData['phone'],
          address: userData['address'],
          bloodType: userData['blood_type'],
          medicalHistory: userData['medical_history'],
          allergies: userData['allergies'],
          insuranceName: userData['insurance_name'],
          insurancePolicyNumber: userData['insurance_policy_number'],
          nik: userData['nik'],
          username: userData['username'],
          dateOfBirth: userData['date_of_birth'],
          gender: userData['gender'],
          city: userData['city'],
          province: userData['province'],
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Simpan data user ke SharedPreferences
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

  // Load user data dari SharedPreferences (fallback jika offline)
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
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiService.registerEndpoint,
        {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phone': phoneNumber,
        },
      );

      debugPrint('Register response: $response');

      if (response['success'] == true || response['status'] == 'success') {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Register error: $e');
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
      // Panggil API logout
      final response = await _apiService.post(ApiService.logoutEndpoint, {});
      debugPrint('Logout response: $response');
    } catch (e) {
      debugPrint('Logout API error (ignored): $e');
      // Tetap lanjut hapus data lokal meskipun API error
    }

    // Hapus semua data dari SharedPreferences
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

      final response = await _apiService.get(ApiService.patientProfile);
      debugPrint('Load profile response: $response');

      if (response['status'] == 'success') {
        final data = response['data'];
        final patientData = data['patient'];

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
          dateOfBirth: data['date_of_birth'],
          gender: data['gender'],
          city: data['city'],
          province: data['province'],
        );

        // Update SharedPreferences dengan data terbaru
        await _updatePrefsFromCurrentUser();

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update SharedPreferences dengan data user terbaru
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

      final Map<String, dynamic> userData = {
        'name': updatedUser.name,
        'phone': updatedUser.phoneNumber,
        'address': updatedUser.address,
        'nik': updatedUser.nik,
        'username': updatedUser.username,
        'date_of_birth': updatedUser.dateOfBirth,
        'gender': updatedUser.gender,
        'city': updatedUser.city,
        'province': updatedUser.province,
      };

      final Map<String, dynamic> patientData = {
        'blood_type': updatedUser.bloodType,
        'medical_history': updatedUser.medicalHistory,
        'allergies': updatedUser.allergies,
        'insurance_provider': updatedUser.insuranceName,
        'insurance_number': updatedUser.insurancePolicyNumber,
      };

      userData.removeWhere((key, value) => value == null);
      patientData.removeWhere((key, value) => value == null);

      final Map<String, dynamic> requestData = {
        ...userData,
        ...patientData,
      };

      final response = await _apiService.put(
        ApiService.patientProfile,
        requestData,
      );

      debugPrint('Update profile response: $response');

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
      debugPrint('Error updating profile: $e');
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