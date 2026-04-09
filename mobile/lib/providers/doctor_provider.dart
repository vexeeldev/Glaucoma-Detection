import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../services/api_service.dart';

class DoctorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<DoctorModel> _doctors = [];
  List<String> _specializations = [];
  bool _isLoading = false;

  List<DoctorModel> get doctors => _doctors;
  List<String> get specializations => _specializations;
  bool get isLoading => _isLoading;

  Future<void> loadDoctors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiService.patientDoctors);

      if (response['success'] == true) {
        final List data = response['data'];
        _doctors = data.map((json) => DoctorModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading doctors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSpecializations() async {
    try {
      final response = await _apiService.get(ApiService.patientSpecializations);

      if (response['success'] == true) {
        _specializations = List<String>.from(response['data']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading specializations: $e');
    }
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    try {
      final response = await _apiService.get('${ApiService.patientDoctors}/$id');

      if (response['success'] == true) {
        return DoctorModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting doctor: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getDoctorSchedules(String doctorId) async {
    try {
      final response = await _apiService.get(
          '${ApiService.patientDoctors}/$doctorId/schedules'
      );

      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting schedules: $e');
      return [];
    }
  }
}