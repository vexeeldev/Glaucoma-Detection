import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/doctor_model.dart';
import '../services/api_service.dart';

class DoctorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<DoctorModel> _doctors = [];
  List<String> _specializations = [];
  DoctorModel? _selectedDoctor;
  List<AvailableSlot> _availableSlots = [];
  final Map<int, bool> _doctorAvailabilityCache = {}; // Tambahkan 'final'
  bool _isLoading = false;
  bool _isCheckingAvailability = false;

  List<DoctorModel> get doctors => _doctors;
  List<String> get specializations => _specializations;
  DoctorModel? get selectedDoctor => _selectedDoctor;
  List<AvailableSlot> get availableSlots => _availableSlots;
  bool get isLoading => _isLoading;
  bool get isCheckingAvailability => _isCheckingAvailability;

  // Cek availability untuk satu dokter (dengan cache)
  Future<bool> isDoctorAvailableToday(int doctorId) async {
    // Cek cache dulu
    if (_doctorAvailabilityCache.containsKey(doctorId)) {
      return _doctorAvailabilityCache[doctorId]!;
    }

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await _apiService.get(
          '${ApiService.patientDoctors}/$doctorId/schedules?date=$formattedDate'
      );

      bool isAvailable = false;
      if (response['status'] == 'success') {
        final data = response['data'];
        if (data != null && data.isNotEmpty) {
          final slots = data[0]['available_slots'];
          isAvailable = slots != null && slots.isNotEmpty;
        }
      }

      // Simpan ke cache
      _doctorAvailabilityCache[doctorId] = isAvailable;
      return isAvailable;
    } catch (e) {
      debugPrint('Error checking availability for doctor $doctorId: $e');
      return false;
    }
  }

  // Cek availability untuk semua dokter di list
  Future<Map<int, bool>> checkDoctorsAvailability(List<DoctorModel> doctors) async {
    final Map<int, bool> results = {};
    _isCheckingAvailability = true;
    notifyListeners();

    for (var doctor in doctors) {
      results[doctor.id] = await isDoctorAvailableToday(doctor.id);
    }

    _isCheckingAvailability = false;
    notifyListeners();
    return results;
  }

  Future<void> loadDoctors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiService.patientDoctors);
      debugPrint('Load doctors response: $response');

      if (response['status'] == 'success') {
        final List data = response['data'];
        _doctors = data.map((json) => DoctorModel.fromJson(json)).toList();

        final specs = _doctors.map((d) => d.specialization).toSet();
        _specializations = specs.toList();

        // Clear cache saat load ulang
        _doctorAvailabilityCache.clear();
      }
    } catch (e) {
      debugPrint('Error loading doctors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DoctorModel?> loadDoctorDetail(int doctorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('${ApiService.patientDoctors}/$doctorId');
      debugPrint('Load doctor detail response: $response');

      if (response['status'] == 'success') {
        _selectedDoctor = DoctorModel.fromJson(response['data']);
        notifyListeners();
        return _selectedDoctor;
      }
      return null;
    } catch (e) {
      debugPrint('Error loading doctor detail: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkDoctorAvailabilityToday(int doctorId, DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await _apiService.get(
          '${ApiService.patientDoctors}/$doctorId/schedules?date=$formattedDate'
      );
      debugPrint('Check availability response: $response');

      if (response['status'] == 'success') {
        final data = response['data'];
        if (data != null && data.isNotEmpty) {
          final slots = data[0]['available_slots'];
          if (slots != null && slots.isNotEmpty) {
            _availableSlots = (slots as List).map((slot) => AvailableSlot.fromJson(slot)).toList();
            notifyListeners();
            return _availableSlots.isNotEmpty;
          }
        }
      }
      _availableSlots = [];
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error checking availability: $e');
      _availableSlots = [];
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSpecializations() async {
    try {
      final response = await _apiService.get(ApiService.patientSpecializations);
      if (response['status'] == 'success') {
        _specializations = List<String>.from(response['data']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading specializations: $e');
    }
  }

  void clearSelectedDoctor() {
    _selectedDoctor = null;
    _availableSlots = [];
    notifyListeners();
  }

  void clearAvailabilityCache() {
    _doctorAvailabilityCache.clear();
    notifyListeners();
  }
}

// Model untuk AvailableSlot
class AvailableSlot {
  final int scheduleId;
  final String time;
  final String status;
  final int maxPatients;
  final int booked;
  final int remaining;
  final bool isFull;

  AvailableSlot({
    required this.scheduleId,
    required this.time,
    required this.status,
    required this.maxPatients,
    required this.booked,
    required this.remaining,
    required this.isFull,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      scheduleId: json['schedule_id'],
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      maxPatients: json['max_patients'] ?? 0,
      booked: json['booked'] ?? 0,
      remaining: json['remaining'] ?? 0,
      isFull: json['is_full'] ?? false,
    );
  }
}