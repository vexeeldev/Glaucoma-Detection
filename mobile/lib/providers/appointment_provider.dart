import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../models/examination_model.dart';
import '../services/mock_data_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final MockDataService _mockDataService = MockDataService();
  List<AppointmentModel> _appointments = [];
  List<ExaminationModel> _examinations = [];

  List<AppointmentModel> get appointments => _appointments;
  List<ExaminationModel> get examinations => _examinations;

  Future<void> loadAppointments(String userId, String role) async {
    if (role == 'pasien') {
      _appointments = _mockDataService.getAppointmentsByPatient(userId);
    } else {
      _appointments = _mockDataService.getAppointmentsByDoctor(userId);
    }
    notifyListeners();
  }

  Future<void> loadExaminations(String userId, String role) async {
    if (role == 'pasien') {
      _examinations = _mockDataService.getExaminationsByPatient(userId);
    } else {
      _examinations = _mockDataService.getExaminationsByDoctor(userId);
    }
    notifyListeners();
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
      final newAppointment = AppointmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        doctorId: doctorId,
        doctorName: doctorName,
        date: date,
        time: time,
        complaint: complaint,
        status: 'pending',
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      _mockDataService.addAppointment(newAppointment);
      _appointments.add(newAppointment);
      notifyListeners();

      // Create notification for doctor
      // This would be handled in a real app

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId,
      String status, {
        String? rejectionReason,
      }) async {
    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      final updatedAppointment = AppointmentModel(
        id: _appointments[index].id,
        patientId: _appointments[index].patientId,
        doctorId: _appointments[index].doctorId,
        doctorName: _appointments[index].doctorName,
        date: _appointments[index].date,
        time: _appointments[index].time,
        complaint: _appointments[index].complaint,
        status: status,
        rejectionReason: rejectionReason,
        paymentMethod: _appointments[index].paymentMethod,
        createdAt: _appointments[index].createdAt,
      );

      _mockDataService.updateAppointment(updatedAppointment);
      _appointments[index] = updatedAppointment;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    final appointment = _appointments.firstWhere((apt) => apt.id == appointmentId);

    if (appointment.status == 'pending' ||
        appointment.status == 'paid' ||
        appointment.status == 'confirmed') {
      await updateAppointmentStatus(appointmentId, 'cancelled');
      return true;
    }
    return false;
  }

  Future<void> updateExamination(ExaminationModel examination) async {
    final index = _examinations.indexWhere((exam) => exam.id == examination.id);
    if (index != -1) {
      _mockDataService.updateExamination(examination);
      _examinations[index] = examination;
      notifyListeners();
    }
  }

  List<AppointmentModel> getFilteredAppointments(String status) {
    return _appointments.where((apt) => apt.status == status).toList();
  }

  List<ExaminationModel> getPatientExaminations(String patientId) {
    return _examinations.where((exam) => exam.patientId == patientId).toList();
  }
}