import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import '../models/user_model.dart';
import '../models/doctor_model.dart' as doctor;
import '../models/appointment_model.dart';
import '../models/examination_model.dart';
import '../models/notification_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  Map<String, dynamic> _data = {
    'users': [],
    'doctors': [],
    'appointments': [],
    'examinations': [],
    'notifications': [],
  };

  bool _isInitialized = false;

  void _log(String message) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print(message);
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadMockData();
    _isInitialized = true;
  }

  Future<void> loadMockData() async {
    try {
      // Try to load from assets first
      final String response = await rootBundle.loadString('assets/mock_data.json');
      _data = json.decode(response);
      _log('Mock data loaded successfully from assets');
    } catch (e) {
      _log('Error loading mock data from assets: $e');
      _log('Initializing with default data...');
      _initializeDefaultData();
    }
  }

  void _initializeDefaultData() {
    _data = {
      'users': [
        {
          'id': '1',
          'name': 'John Doe',
          'email': 'john@example.com',
          'password': 'password123',
          'role': 'pasien',
          'phoneNumber': '081234567890',
          'address': 'Jl. Contoh No. 123, Jakarta',
          'bloodType': 'O',
          'medicalHistory': 'Hipertensi',
          'allergies': 'Debu, Udang',
          'insuranceName': 'BPJS Kesehatan',
          'insurancePolicyNumber': '1234567890',
        },
        {
          'id': '2',
          'name': 'Sarah Wijaya',
          'email': 'sarah@eyecare.com',
          'password': 'doctor123',
          'role': 'dokter',
          'phoneNumber': '081298765432',
          'address': 'Jl. Dokter No. 45, Jakarta',
          'bloodType': null,
          'medicalHistory': null,
          'allergies': null,
          'insuranceName': null,
          'insurancePolicyNumber': null,
        },
        {
          'id': '3',
          'name': 'Budi Santoso',
          'email': 'budi@eyecare.com',
          'password': 'doctor456',
          'role': 'dokter',
          'phoneNumber': '081234567891',
          'address': 'Jl. Kesehatan No. 78, Surabaya',
          'bloodType': null,
          'medicalHistory': null,
          'allergies': null,
          'insuranceName': null,
          'insurancePolicyNumber': null,
        },
      ],
      'doctors': [
        {
          'id': '2',
          'name': 'Dr. Sarah Wijaya, Sp.M',
          'specialization': 'Spesialis Mata',
          'photoUrl': 'assets/images/doctor1.jpg',
          'schedule': 'Senin-Jumat, 09:00-17:00',
          'availableQuota': 10,
          'isAvailable': true,
          'about': 'Dokter spesialis mata dengan pengalaman 10 tahun. Lulusan Universitas Indonesia dengan predikat cum laude. Aktif dalam penelitian tentang glaukoma dan telah mempublikasikan berbagai jurnal internasional.',
          'experience': 10,
          'education': 'Spesialis Mata - Universitas Indonesia\nDokter Umum - Universitas Indonesia',
          'hospital': 'RS Mata Jakarta',
          'rating': 4.8,
          'totalPatients': 1250,
        },
        {
          'id': '3',
          'name': 'Dr. Budi Santoso, Sp.M(K)',
          'specialization': 'Glaukoma Specialist',
          'photoUrl': 'assets/images/doctor2.jpg',
          'schedule': 'Selasa-Kamis, 10:00-18:00',
          'availableQuota': 5,
          'isAvailable': true,
          'about': 'Spesialis glaukoma dengan fellowship di Tokyo University, Jepang. Memiliki pengalaman lebih dari 8 tahun dalam menangani kasus glaukoma kompleks. Aktif sebagai pembicara di berbagai seminar internasional.',
          'experience': 8,
          'education': 'Konsultan Glaukoma - Tokyo University\nSpesialis Mata - Universitas Airlangga\nDokter Umum - Universitas Airlangga',
          'hospital': 'RS Mata Surabaya',
          'rating': 4.9,
          'totalPatients': 850,
        },
        {
          'id': '4',
          'name': 'Dr. Maya Putri, Sp.M',
          'specialization': 'Spesialis Mata',
          'photoUrl': 'assets/images/doctor3.jpg',
          'schedule': 'Senin-Rabu, 08:00-15:00',
          'availableQuota': 8,
          'isAvailable': true,
          'about': 'Dokter spesialis mata dengan fokus pada kesehatan mata anak. Lulusan Universitas Gadjah Mada dan berpengalaman dalam penanganan gangguan refraksi pada anak.',
          'experience': 6,
          'education': 'Spesialis Mata - Universitas Gadjah Mada\nDokter Umum - Universitas Gadjah Mada',
          'hospital': 'RS Anak Bunda',
          'rating': 4.7,
          'totalPatients': 620,
        },
      ],
      'appointments': [
        {
          'id': '1',
          'patientId': '1',
          'doctorId': '2',
          'doctorName': 'Dr. Sarah Wijaya, Sp.M',
          'date': '2024-02-01T10:00:00',
          'time': '10:00',
          'complaint': 'Mata terasa pedas dan berair sejak 3 hari terakhir. Terutama saat terkena debu atau setelah menatap layar komputer terlalu lama.',
          'status': 'completed',
          'rejectionReason': null,
          'paymentMethod': 'Transfer Bank',
          'createdAt': '2024-01-25T08:30:00',
        },
        {
          'id': '2',
          'patientId': '1',
          'doctorId': '2',
          'doctorName': 'Dr. Sarah Wijaya, Sp.M',
          'date': '2024-02-15T14:00:00',
          'time': '14:00',
          'complaint': 'Pemeriksaan rutin glaukoma. Riwayat keluarga dengan glaukoma, ingin melakukan screening.',
          'status': 'confirmed',
          'rejectionReason': null,
          'paymentMethod': 'E-Wallet',
          'createdAt': '2024-02-01T09:15:00',
        },
        {
          'id': '3',
          'patientId': '1',
          'doctorId': '3',
          'doctorName': 'Dr. Budi Santoso, Sp.M(K)',
          'date': '2024-02-20T09:00:00',
          'time': '09:00',
          'complaint': 'Keluhan mata buram sebelah kiri, terutama saat membaca. Sudah berlangsung selama 2 minggu.',
          'status': 'paid',
          'rejectionReason': null,
          'paymentMethod': 'Transfer Bank',
          'createdAt': '2024-02-05T14:20:00',
        },
        {
          'id': '4',
          'patientId': '1',
          'doctorId': '4',
          'doctorName': 'Dr. Maya Putri, Sp.M',
          'date': '2024-01-10T11:00:00',
          'time': '11:00',
          'complaint': 'Pemeriksaan mata rutin tahunan',
          'status': 'cancelled',
          'rejectionReason': 'Pasien membatalkan karena ada keperluan mendadak',
          'paymentMethod': 'E-Wallet',
          'createdAt': '2024-01-05T10:00:00',
        },
        {
          'id': '5',
          'patientId': '2',
          'doctorId': '3',
          'doctorName': 'Dr. Budi Santoso, Sp.M(K)',
          'date': '2024-02-18T15:30:00',
          'time': '15:30',
          'complaint': 'Konsultasi hasil pemeriksaan glaukoma dari rumah sakit lain',
          'status': 'pending',
          'rejectionReason': null,
          'paymentMethod': 'Transfer Bank',
          'createdAt': '2024-02-10T16:45:00',
        },
      ],
      'examinations': [
        {
          'id': '1',
          'appointmentId': '1',
          'patientId': '1',
          'patientName': 'John Doe',
          'doctorId': '2',
          'doctorName': 'Dr. Sarah Wijaya, Sp.M',
          'examinationDate': '2024-02-01T10:30:00',
          'fundusPhotoUrl': 'assets/images/fundus_normal_1.jpg',
          'prediction': 'Normal',
          'confidenceScore': 0.95,
          'gradCamHeatmap': 'assets/images/heatmap_normal_1.jpg',
          'doctorDiagnosis': 'Hasil pemeriksaan fundus menunjukkan kondisi mata normal. Tidak ditemukan tanda-tanda glaukoma. Tekanan intraokular dalam batas normal (14 mmHg). Papil saraf optik sehat dengan cup-to-disc ratio normal (0.3).',
          'doctorRecommendation': '1. Pemeriksaan rutin 6 bulan sekali\n2. Gunakan kacamata anti radiasi jika bekerja di depan komputer\n3. Istirahatkan mata setiap 20 menit dengan melihat jarak jauh\n4. Konsumsi makanan kaya vitamin A',
          'status': 'completed',
        },
        {
          'id': '2',
          'appointmentId': '5',
          'patientId': '2',
          'patientName': 'Jane Smith',
          'doctorId': '3',
          'doctorName': 'Dr. Budi Santoso, Sp.M(K)',
          'examinationDate': '2024-02-18T16:00:00',
          'fundusPhotoUrl': 'assets/images/fundus_glaucoma_1.jpg',
          'prediction': 'Glaukoma',
          'confidenceScore': 0.88,
          'gradCamHeatmap': 'assets/images/heatmap_glaucoma_1.jpg',
          'doctorDiagnosis': null,
          'doctorRecommendation': null,
          'status': 'pending',
        },
      ],
      'notifications': [
        {
          'id': '1',
          'userId': '1',
          'title': 'Janji Dikonfirmasi',
          'message': 'Janji Anda dengan Dr. Sarah Wijaya, Sp.M pada tanggal 15 Februari 2024 pukul 14:00 telah dikonfirmasi',
          'type': 'appointment_confirmed',
          'isRead': false,
          'createdAt': '2024-02-01T11:00:00',
          'data': {'appointmentId': '2'},
        },
        {
          'id': '2',
          'userId': '2',
          'title': 'Janji Baru',
          'message': 'Ada janji baru dari John Doe pada tanggal 20 Februari 2024 pukul 09:00',
          'type': 'new_appointment',
          'isRead': true,
          'createdAt': '2024-02-05T14:20:00',
          'data': {'appointmentId': '3'},
        },
        {
          'id': '3',
          'userId': '1',
          'title': 'Pembayaran Berhasil',
          'message': 'Pembayaran untuk janji dengan Dr. Budi Santoso, Sp.M(K) sebesar Rp 350.000 telah berhasil',
          'type': 'payment_success',
          'isRead': false,
          'createdAt': '2024-02-05T14:25:00',
          'data': {'appointmentId': '3'},
        },
        {
          'id': '4',
          'userId': '1',
          'title': 'Hasil Pemeriksaan Tersedia',
          'message': 'Hasil pemeriksaan Anda dengan Dr. Sarah Wijaya, Sp.M sudah tersedia. Klik untuk melihat detail',
          'type': 'examination_ready',
          'isRead': true,
          'createdAt': '2024-02-01T14:00:00',
          'data': {'examinationId': '1'},
        },
        {
          'id': '5',
          'userId': '2',
          'title': 'Hasil ML Selesai',
          'message': 'Hasil analisis AI untuk pemeriksaan pasien Jane Smith sudah selesai diproses',
          'type': 'ml_processed',
          'isRead': false,
          'createdAt': '2024-02-18T16:30:00',
          'data': {'examinationId': '2'},
        },
        {
          'id': '6',
          'userId': '3',
          'title': 'Janji Baru',
          'message': 'Ada janji baru dari Jane Smith pada tanggal 18 Februari 2024 pukul 15:30',
          'type': 'new_appointment',
          'isRead': false,
          'createdAt': '2024-02-10T16:45:00',
          'data': {'appointmentId': '5'},
        },
      ],
    };
    _log('Default mock data initialized');
  }

  // ==================== USER METHODS ====================

  List<UserModel> getUsers() {
    _ensureInitialized();
    try {
      return (_data['users'] as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting users: $e');
      return [];
    }
  }

  UserModel? getUserById(String id) {
    _ensureInitialized();
    try {
      final userJson = (_data['users'] as List).firstWhere(
            (user) => user['id'] == id,
      );
      return UserModel.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  UserModel? getUserByEmail(String email) {
    _ensureInitialized();
    try {
      final userJson = (_data['users'] as List).firstWhere(
            (user) => user['email'].toLowerCase() == email.toLowerCase(),
      );
      return UserModel.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  void addUser(UserModel user) {
    _ensureInitialized();
    try {
      _data['users'].add(user.toJson());
      _log('User added: ${user.email}');
    } catch (e) {
      _log('Error adding user: $e');
    }
  }

  void updateUser(UserModel user) {
    _ensureInitialized();
    try {
      final index = (_data['users'] as List).indexWhere((u) => u['id'] == user.id);
      if (index != -1) {
        _data['users'][index] = user.toJson();
        _log('User updated: ${user.id}');
      }
    } catch (e) {
      _log('Error updating user: $e');
    }
  }

  void deleteUser(String id) {
    _ensureInitialized();
    try {
      _data['users'].removeWhere((user) => user['id'] == id);
      _log('User deleted: $id');
    } catch (e) {
      _log('Error deleting user: $e');
    }
  }

  // ==================== DOCTOR METHODS ====================

  List<doctor.DoctorModel> getDoctors() {
    _ensureInitialized();
    try {
      return (_data['doctors'] as List)
          .map((json) => doctor.DoctorModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting doctors: $e');
      return [];
    }
  }

  List<doctor.DoctorModel> getAvailableDoctors() {
    _ensureInitialized();
    try {
      return (_data['doctors'] as List)
          .where((doctor) => doctor['isAvailable'] == true)
          .map((json) => doctor.DoctorModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting available doctors: $e');
      return [];
    }
  }

  doctor.DoctorModel? getDoctorById(String id) {
    _ensureInitialized();
    try {
      final doctorJson = (_data['doctors'] as List).firstWhere(
            (doctor) => doctor['id'] == id,
      );
      return doctor.DoctorModel.fromJson(doctorJson);
    } catch (e) {
      return null;
    }
  }

  List<doctor.DoctorModel> getDoctorsBySpecialization(String specialization) {
    _ensureInitialized();
    try {
      return (_data['doctors'] as List)
          .where((doctor) =>
          doctor['specialization'].toLowerCase().contains(specialization.toLowerCase()))
          .map((json) => doctor.DoctorModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting doctors by specialization: $e');
      return [];
    }
  }

  void updateDoctorAvailability(String doctorId, bool isAvailable) {
    _ensureInitialized();
    try {
      final index = (_data['doctors'] as List).indexWhere((d) => d['id'] == doctorId);
      if (index != -1) {
        _data['doctors'][index]['isAvailable'] = isAvailable;
        _log('Doctor availability updated: $doctorId -> $isAvailable');
      }
    } catch (e) {
      _log('Error updating doctor availability: $e');
    }
  }

  void decrementDoctorQuota(String doctorId) {
    _ensureInitialized();
    try {
      final index = (_data['doctors'] as List).indexWhere((d) => d['id'] == doctorId);
      if (index != -1) {
        int currentQuota = _data['doctors'][index]['availableQuota'];
        if (currentQuota > 0) {
          _data['doctors'][index]['availableQuota'] = currentQuota - 1;
          if (currentQuota - 1 == 0) {
            _data['doctors'][index]['isAvailable'] = false;
          }
          _log('Doctor quota decremented: $doctorId');
        }
      }
    } catch (e) {
      _log('Error decrementing doctor quota: $e');
    }
  }

  // ==================== APPOINTMENT METHODS ====================

  List<AppointmentModel> getAppointments() {
    _ensureInitialized();
    try {
      return (_data['appointments'] as List)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting appointments: $e');
      return [];
    }
  }

  List<AppointmentModel> getAppointmentsByPatient(String patientId) {
    _ensureInitialized();
    try {
      return (_data['appointments'] as List)
          .where((apt) => apt['patientId'] == patientId)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting appointments by patient: $e');
      return [];
    }
  }

  List<AppointmentModel> getAppointmentsByDoctor(String doctorId) {
    _ensureInitialized();
    try {
      return (_data['appointments'] as List)
          .where((apt) => apt['doctorId'] == doctorId)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting appointments by doctor: $e');
      return [];
    }
  }

  List<AppointmentModel> getAppointmentsByStatus(String status) {
    _ensureInitialized();
    try {
      return (_data['appointments'] as List)
          .where((apt) => apt['status'] == status)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting appointments by status: $e');
      return [];
    }
  }

  List<AppointmentModel> getAppointmentsByDateRange(DateTime start, DateTime end) {
    _ensureInitialized();
    try {
      return (_data['appointments'] as List)
          .where((apt) {
        final aptDate = DateTime.parse(apt['date']);
        return aptDate.isAfter(start) && aptDate.isBefore(end);
      })
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting appointments by date range: $e');
      return [];
    }
  }

  AppointmentModel? getAppointmentById(String id) {
    _ensureInitialized();
    try {
      final aptJson = (_data['appointments'] as List).firstWhere(
            (apt) => apt['id'] == id,
      );
      return AppointmentModel.fromJson(aptJson);
    } catch (e) {
      return null;
    }
  }

  void addAppointment(AppointmentModel appointment) {
    _ensureInitialized();
    try {
      _data['appointments'].add(appointment.toJson());
      // Decrement doctor quota
      decrementDoctorQuota(appointment.doctorId);
      _log('Appointment added: ${appointment.id}');
    } catch (e) {
      _log('Error adding appointment: $e');
    }
  }

  void updateAppointment(AppointmentModel appointment) {
    _ensureInitialized();
    try {
      final index = (_data['appointments'] as List)
          .indexWhere((apt) => apt['id'] == appointment.id);
      if (index != -1) {
        _data['appointments'][index] = appointment.toJson();
        _log('Appointment updated: ${appointment.id}');
      }
    } catch (e) {
      _log('Error updating appointment: $e');
    }
  }

  void updateAppointmentStatus(String appointmentId, String status, {String? rejectionReason}) {
    _ensureInitialized();
    try {
      final index = (_data['appointments'] as List)
          .indexWhere((apt) => apt['id'] == appointmentId);
      if (index != -1) {
        _data['appointments'][index]['status'] = status;
        if (rejectionReason != null) {
          _data['appointments'][index]['rejectionReason'] = rejectionReason;
        }
        _log('Appointment status updated: $appointmentId -> $status');
      }
    } catch (e) {
      _log('Error updating appointment status: $e');
    }
  }

  void deleteAppointment(String id) {
    _ensureInitialized();
    try {
      _data['appointments'].removeWhere((apt) => apt['id'] == id);
      _log('Appointment deleted: $id');
    } catch (e) {
      _log('Error deleting appointment: $e');
    }
  }

  // ==================== EXAMINATION METHODS ====================

  List<ExaminationModel> getExaminations() {
    _ensureInitialized();
    try {
      return (_data['examinations'] as List)
          .map((json) => ExaminationModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting examinations: $e');
      return [];
    }
  }

  List<ExaminationModel> getExaminationsByPatient(String patientId) {
    _ensureInitialized();
    try {
      return (_data['examinations'] as List)
          .where((exam) => exam['patientId'] == patientId)
          .map((json) => ExaminationModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting examinations by patient: $e');
      return [];
    }
  }

  List<ExaminationModel> getExaminationsByDoctor(String doctorId) {
    _ensureInitialized();
    try {
      return (_data['examinations'] as List)
          .where((exam) => exam['doctorId'] == doctorId)
          .map((json) => ExaminationModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting examinations by doctor: $e');
      return [];
    }
  }

  ExaminationModel? getExaminationById(String id) {
    _ensureInitialized();
    try {
      final examJson = (_data['examinations'] as List).firstWhere(
            (exam) => exam['id'] == id,
      );
      return ExaminationModel.fromJson(examJson);
    } catch (e) {
      return null;
    }
  }

  ExaminationModel? getExaminationByAppointment(String appointmentId) {
    _ensureInitialized();
    try {
      final examJson = (_data['examinations'] as List).firstWhere(
            (exam) => exam['appointmentId'] == appointmentId,
      );
      return ExaminationModel.fromJson(examJson);
    } catch (e) {
      return null;
    }
  }

  void addExamination(ExaminationModel examination) {
    _ensureInitialized();
    try {
      _data['examinations'].add(examination.toJson());
      _log('Examination added: ${examination.id}');
    } catch (e) {
      _log('Error adding examination: $e');
    }
  }

  void updateExamination(ExaminationModel examination) {
    _ensureInitialized();
    try {
      final index = (_data['examinations'] as List)
          .indexWhere((exam) => exam['id'] == examination.id);
      if (index != -1) {
        _data['examinations'][index] = examination.toJson();
        _log('Examination updated: ${examination.id}');
      }
    } catch (e) {
      _log('Error updating examination: $e');
    }
  }

  void updateExaminationDiagnosis(String examinationId, String diagnosis, String recommendation) {
    _ensureInitialized();
    try {
      final index = (_data['examinations'] as List)
          .indexWhere((exam) => exam['id'] == examinationId);
      if (index != -1) {
        _data['examinations'][index]['doctorDiagnosis'] = diagnosis;
        _data['examinations'][index]['doctorRecommendation'] = recommendation;
        _data['examinations'][index]['status'] = 'completed';
        _log('Examination diagnosis updated: $examinationId');
      }
    } catch (e) {
      _log('Error updating examination diagnosis: $e');
    }
  }

  // ==================== NOTIFICATION METHODS ====================

  List<NotificationModel> getNotifications() {
    _ensureInitialized();
    try {
      return (_data['notifications'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting notifications: $e');
      return [];
    }
  }

  List<NotificationModel> getNotificationsByUser(String userId) {
    _ensureInitialized();
    try {
      return (_data['notifications'] as List)
          .where((notif) => notif['userId'] == userId)
          .map((json) => NotificationModel.fromJson(json))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _log('Error getting notifications by user: $e');
      return [];
    }
  }

  List<NotificationModel> getUnreadNotifications(String userId) {
    _ensureInitialized();
    try {
      return (_data['notifications'] as List)
          .where((notif) => notif['userId'] == userId && !notif['isRead'])
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error getting unread notifications: $e');
      return [];
    }
  }

  int getUnreadNotificationCount(String userId) {
    _ensureInitialized();
    try {
      return (_data['notifications'] as List)
          .where((notif) => notif['userId'] == userId && !notif['isRead'])
          .length;
    } catch (e) {
      _log('Error getting unread notification count: $e');
      return 0;
    }
  }

  void addNotification(NotificationModel notification) {
    _ensureInitialized();
    try {
      _data['notifications'].add(notification.toJson());
      _log('Notification added: ${notification.id}');
    } catch (e) {
      _log('Error adding notification: $e');
    }
  }

  void markNotificationAsRead(String notificationId) {
    _ensureInitialized();
    try {
      final index = (_data['notifications'] as List)
          .indexWhere((notif) => notif['id'] == notificationId);
      if (index != -1) {
        _data['notifications'][index]['isRead'] = true;
        _log('Notification marked as read: $notificationId');
      }
    } catch (e) {
      _log('Error marking notification as read: $e');
    }
  }

  void markAllNotificationsAsRead(String userId) {
    _ensureInitialized();
    try {
      for (var notification in _data['notifications']) {
        if (notification['userId'] == userId) {
          notification['isRead'] = true;
        }
      }
      _log('All notifications marked as read for user: $userId');
    } catch (e) {
      _log('Error marking all notifications as read: $e');
    }
  }

  void deleteNotification(String id) {
    _ensureInitialized();
    try {
      _data['notifications'].removeWhere((notif) => notif['id'] == id);
      _log('Notification deleted: $id');
    } catch (e) {
      _log('Error deleting notification: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  void _ensureInitialized() {
    if (!_isInitialized) {
      _initializeDefaultData();
      _isInitialized = true;
    }
  }

  bool isInitialized() {
    return _isInitialized;
  }

  void resetToDefault() {
    _initializeDefaultData();
    _log('Data reset to default');
  }

  Map<String, dynamic> getAllData() {
    _ensureInitialized();
    return Map.from(_data);
  }

  void printAllData() {
    _ensureInitialized();
    _log('=== CURRENT MOCK DATA ===');
    _log('Users: ${(_data['users'] as List).length}');
    _log('Doctors: ${(_data['doctors'] as List).length}');
    _log('Appointments: ${(_data['appointments'] as List).length}');
    _log('Examinations: ${(_data['examinations'] as List).length}');
    _log('Notifications: ${(_data['notifications'] as List).length}');
    _log('=========================');
  }

  // ==================== SEARCH METHODS ====================

  List<doctor.DoctorModel> searchDoctors(String query) {
    _ensureInitialized();
    try {
      final lowercaseQuery = query.toLowerCase();
      return (_data['doctors'] as List)
          .where((doctor) {
        return doctor['name'].toLowerCase().contains(lowercaseQuery) ||
            doctor['specialization'].toLowerCase().contains(lowercaseQuery) ||
            (doctor['hospital']?.toLowerCase().contains(lowercaseQuery) ?? false);
      })
          .map((json) => doctor.DoctorModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error searching doctors: $e');
      return [];
    }
  }

  List<AppointmentModel> searchAppointments(String patientId, String query) {
    _ensureInitialized();
    try {
      final lowercaseQuery = query.toLowerCase();
      return (_data['appointments'] as List)
          .where((apt) {
        if (apt['patientId'] != patientId) return false;
        return apt['doctorName'].toLowerCase().contains(lowercaseQuery) ||
            apt['complaint'].toLowerCase().contains(lowercaseQuery);
      })
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('Error searching appointments: $e');
      return [];
    }
  }

  // ==================== STATISTICS METHODS ====================

  Map<String, int> getAppointmentStatistics(String doctorId) {
    _ensureInitialized();
    try {
      final appointments = getAppointmentsByDoctor(doctorId);
      return {
        'total': appointments.length,
        'pending': appointments.where((a) => a.status == 'pending').length,
        'paid': appointments.where((a) => a.status == 'paid').length,
        'confirmed': appointments.where((a) => a.status == 'confirmed').length,
        'completed': appointments.where((a) => a.status == 'completed').length,
        'cancelled': appointments.where((a) => a.status == 'cancelled').length,
        'rejected': appointments.where((a) => a.status == 'rejected').length,
      };
    } catch (e) {
      _log('Error getting appointment statistics: $e');
      return {};
    }
  }

  Map<String, dynamic> getPatientStatistics(String patientId) {
    _ensureInitialized();
    try {
      final appointments = getAppointmentsByPatient(patientId);
      final examinations = getExaminationsByPatient(patientId);

      return {
        'totalAppointments': appointments.length,
        'totalExaminations': examinations.length,
        'completedAppointments': appointments.where((a) => a.status == 'completed').length,
        'upcomingAppointments': appointments.where((a) =>
        a.status == 'confirmed' && a.date.isAfter(DateTime.now())).length,
        'glaucomaDetections': examinations.where((e) => e.prediction == 'Glaukoma').length,
        'normalResults': examinations.where((e) => e.prediction == 'Normal').length,
      };
    } catch (e) {
      _log('Error getting patient statistics: $e');
      return {};
    }
  }
}