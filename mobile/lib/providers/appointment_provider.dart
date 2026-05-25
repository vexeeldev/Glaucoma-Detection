import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../models/examination_model.dart';
import '../services/api_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<AppointmentModel> _appointments = [];
  List<ExaminationModel> _examinations = [];
  bool _isLoading = false;

  List<AppointmentModel> get appointments => _appointments;
  List<ExaminationModel> get examinations => _examinations;
  bool get isLoading => _isLoading;

  // ✅ Method khusus untuk load appointments dokter
  Future<void> loadDoctorAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiService.doctorAppointments);
      debugPrint('📥 Load doctor appointments response: $response');

      List<AppointmentModel> newAppointments = [];

      if (response['status'] == 'success') {
        final data = response['data'];
        if (data is List) {
          newAppointments = data.map((json) => AppointmentModel.fromJson(json)).toList();
        }
        debugPrint('✅ Loaded ${newAppointments.length} doctor appointments');
        _appointments = newAppointments;
      }
    } catch (e) {
      debugPrint('❌ Error loading doctor appointments: $e');
      _appointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Perbaiki loadAppointments untuk memilih endpoint berdasarkan role
  Future<void> loadAppointments(String userId, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Jika dokter, panggil endpoint dokter
      if (role == 'dokter' || role == 'doctor') {
        await loadDoctorAppointments();
        return;
      }
      
      // Untuk pasien
      final endpoint = ApiService.patientBooking;
      final response = await _apiService.get(endpoint);
      debugPrint('📥 Load appointments response: $response');

      List<AppointmentModel> newAppointments = [];

      if (response['data'] != null && response['data'] is List) {
        newAppointments = (response['data'] as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
        debugPrint('✅ Loaded ${newAppointments.length} appointments');
      }

      _appointments = newAppointments;
    } catch (e) {
      debugPrint('❌ Error loading appointments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Perbaiki updateAppointmentStatus untuk dokter
  Future<void> updateAppointmentStatus(
      String appointmentId,
      String status, {
        String? rejectionReason,
      }) async {
    try {
      final endpoint = '/api/mobile/doctor/appointments/$appointmentId/status';
      final response = await _apiService.put(endpoint, {
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      });

      if (response['success'] == true || response['status'] == 'success') {
        final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
        if (index != -1) {
          _appointments[index].status = status;
          if (rejectionReason != null) {
            _appointments[index].rejectionReason = rejectionReason;
          }
          notifyListeners();
        }
        debugPrint('✅ Appointment $appointmentId updated to $status');
      }
    } catch (e) {
      debugPrint('Error updating appointment: $e');
      rethrow;
    }
  }

  // ✅ Method lainnya tetap sama
  Future<void> loadExaminations(String userId, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final endpoint = role == 'pasien'
          ? ApiService.patientMedicalRecords
          : '/api/mobile/doctor/examinations';

      final response = await _apiService.get(endpoint);
      List<ExaminationModel> newExaminations = [];

      if (response['data'] != null && response['data'] is List) {
        newExaminations = (response['data'] as List)
            .map((json) => ExaminationModel.fromJson(json))
            .toList();
      }

      _examinations = newExaminations;
      debugPrint('✅ Loaded ${_examinations.length} examinations');
    } catch (e) {
      debugPrint('Error loading examinations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      final response = await _apiService.delete('${ApiService.patientBooking}/$appointmentId');
      if (response['status'] == 'success' || response['success'] == true) {
        _appointments.removeWhere((apt) => apt.id == appointmentId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
      return false;
    }
  }

  Future<bool> confirmPayment({required int appointmentId, required String paymentMethod}) async {
    try {
      final response = await _apiService.post(ApiService.patientPayment, {
        'appointment_id': appointmentId,
        'payment_method': paymentMethod,
      });
      return response['status'] == 'success';
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      return false;
    }
  }

  Future<void> updateExamination(ExaminationModel examination) async {
    try {
      final response = await _apiService.put(
        '/api/mobile/examinations/${examination.id}',
        examination.toJson(),
      );
      if (response['success'] == true) {
        final index = _examinations.indexWhere((e) => e.id == examination.id);
        if (index != -1) {
          _examinations[index] = examination;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating examination: $e');
    }
  }

  void clearData() {
    _appointments.clear();
    _examinations.clear();
    notifyListeners();
  }
}