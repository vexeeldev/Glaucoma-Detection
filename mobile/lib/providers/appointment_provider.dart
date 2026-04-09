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

  Future<void> loadAppointments(String userId, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final endpoint = role == 'pasien'
          ? ApiService.patientBooking
          : ApiService.doctorBooking;

      final response = await _apiService.get(endpoint);

      if (response['success'] == true) {
        final List data = response['data'];
        _appointments = data.map((json) => AppointmentModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading appointments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExaminations(String userId, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final endpoint = role == 'pasien'
          ? ApiService.patientMedicalRecords
          : '/api/mobile/doctor/examinations';

      final response = await _apiService.get(endpoint);

      if (response['success'] == true) {
        final List data = response['data'];
        _examinations = data.map((json) => ExaminationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading examinations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookAppointment({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required String time,
    required String complaint,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiService.post(
        ApiService.patientBooking,
        {
          'doctor_id': doctorId,
          'date': date.toIso8601String(),
          'time': time,
          'complaint': complaint,
          'payment_method': paymentMethod,
        },
      );

      if (response['success'] == true) {
        await loadAppointments(patientId, 'pasien');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      return false;
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId,
      String status, {
        String? rejectionReason,
      }) async {
    try {
      final endpoint = '/api/mobile/doctor/booking/$appointmentId/$status';
      final response = await _apiService.put(endpoint, {
        if (rejectionReason != null) 'reason': rejectionReason,
      });

      if (response['success'] == true) {
        final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
        if (index != -1) {
          _appointments[index].status = status;
          if (rejectionReason != null) {
            _appointments[index].rejectionReason = rejectionReason;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating appointment: $e');
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      final response = await _apiService.delete('${ApiService.patientBooking}/$appointmentId');

      if (response['success'] == true) {
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
}