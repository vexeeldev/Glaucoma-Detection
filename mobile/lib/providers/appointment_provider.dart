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
      debugPrint('📥 Load appointments response: $response');

      List<AppointmentModel> newAppointments = [];

      if (response['data'] != null && response['data'] is List) {
        newAppointments = (response['data'] as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
        debugPrint('✅ Loaded ${newAppointments.length} appointments from response[\'data\']');
      }
      else if (response['status'] == 'success' && response['data'] != null) {
        if (response['data'] is List) {
          newAppointments = (response['data'] as List)
              .map((json) => AppointmentModel.fromJson(json))
              .toList();
        } else if (response['data']['data'] != null) {
          newAppointments = (response['data']['data'] as List)
              .map((json) => AppointmentModel.fromJson(json))
              .toList();
        }
        debugPrint('✅ Loaded ${newAppointments.length} appointments from status response');
      }
      else if (response is List) {
        newAppointments = (response as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
        debugPrint('✅ Loaded ${newAppointments.length} appointments from direct list');
      }

      _appointments = newAppointments;
    } catch (e) {
      debugPrint('❌ Error loading appointments: $e');
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

      List<ExaminationModel> newExaminations = [];

      if (response['data'] != null && response['data'] is List) {
        newExaminations = (response['data'] as List)
            .map((json) => ExaminationModel.fromJson(json))
            .toList();
      } else if (response['status'] == 'success' && response['data'] != null) {
        if (response['data'] is List) {
          newExaminations = (response['data'] as List)
              .map((json) => ExaminationModel.fromJson(json))
              .toList();
        } else if (response['data']['data'] != null) {
          newExaminations = (response['data']['data'] as List)
              .map((json) => ExaminationModel.fromJson(json))
              .toList();
        }
      }

      _examinations = newExaminations;
    } catch (e) {
      debugPrint('Error loading examinations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> bookAppointment({
    required int patientId,
    required int doctorId,
    required String appointmentDate,
    required String appointmentTime,
    required String packageType,
    required String patientComplaint,
  }) async {
    try {
      final requestData = {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'package_type': packageType,
        'patient_complaint': patientComplaint,
      };

      debugPrint('📤 Booking request: $requestData');

      final response = await _apiService.post(
        ApiService.patientBooking,
        requestData,
      );

      debugPrint('📥 Booking response: $response');

      if (response['status'] == 'success') {
        await loadAppointments(patientId.toString(), 'pasien');
        return response['data'];
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error booking appointment: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBookingDetail(int bookingId) async {
    try {
      final response = await _apiService.get('${ApiService.patientBooking}/$bookingId');
      debugPrint('📥 Booking detail response: $response');

      if (response['status'] == 'success') {
        return response['data'];
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting booking detail: $e');
      return null;
    }
  }

  // GET payment by appointment ID
  Future<Map<String, dynamic>?> getPaymentByAppointmentId(int appointmentId) async {
    try {
      final response = await _apiService.get('${ApiService.patientPayment}/$appointmentId');
      debugPrint('📥 Payment response: $response');

      if (response['status'] == 'success') {
        return response['data'];
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting payment: $e');
      return null;
    }
  }

  // POST payment (confirm payment)
  Future<bool> confirmPayment({
    required int appointmentId,
    required String paymentMethod,
  }) async {
    try {
      final requestData = {
        'appointment_id': appointmentId,
        'payment_method': paymentMethod,
      };

      debugPrint('📤 Payment request: $requestData');

      final response = await _apiService.post(
        ApiService.patientPayment,
        requestData,
      );

      debugPrint('📥 Payment response: $response');

      if (response['status'] == 'success') {
        // Refresh appointments after payment
        await loadAppointments(appointmentId.toString(), 'pasien');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error confirming payment: $e');
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
      debugPrint('🗑️ Cancelling appointment: $appointmentId');
      final response = await _apiService.delete('${ApiService.patientBooking}/$appointmentId');
      debugPrint('📥 Cancel appointment response: $response');

      if (response['message'] != null) {
        _appointments.removeWhere((apt) => apt.id == appointmentId);
        notifyListeners();
        debugPrint('✅ Appointment $appointmentId cancelled successfully');
        return true;
      }

      if (response['status'] == 'success' || response['success'] == true) {
        _appointments.removeWhere((apt) => apt.id == appointmentId);
        notifyListeners();
        debugPrint('✅ Appointment $appointmentId cancelled successfully');
        return true;
      }

      debugPrint('❌ Failed to cancel appointment: $response');
      return false;
    } catch (e) {
      debugPrint('❌ Error cancelling appointment: $e');
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