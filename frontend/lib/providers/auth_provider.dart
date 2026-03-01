import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  final MockDataService _mockDataService = MockDataService();

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isDokter => _currentUser?.role == 'dokter';
  bool get isPasien => _currentUser?.role == 'pasien';

  Future<bool> login(String email, String password) async {
    try {
      final user = _mockDataService.getUserByEmail(email);

      if (user != null && user.password == password) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Check if email already exists
      final existingUser = _mockDataService.getUserByEmail(email);
      if (existingUser != null) {
        return false;
      }

      // Create new user
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        password: password,
        role: role,
      );

      _mockDataService.addUser(newUser);

      if (role == 'dokter') {
        // Also add to doctors list
        // This would be handled in a real backend
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      if (_currentUser == null) return false;

      if (_currentUser!.password != oldPassword) {
        return false;
      }

      final updatedUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        password: newPassword,
        role: _currentUser!.role,
        phoneNumber: _currentUser!.phoneNumber,
        address: _currentUser!.address,
        bloodType: _currentUser!.bloodType,
        medicalHistory: _currentUser!.medicalHistory,
        allergies: _currentUser!.allergies,
        insuranceName: _currentUser!.insuranceName,
        insurancePolicyNumber: _currentUser!.insurancePolicyNumber,
      );

      _mockDataService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _mockDataService.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}