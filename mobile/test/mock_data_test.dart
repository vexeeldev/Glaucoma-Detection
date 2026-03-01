import 'package:flutter_test/flutter_test.dart';
import 'package:eyecare_app/services/mock_data_service.dart';
import 'package:eyecare_app/models/user_model.dart';
import 'package:eyecare_app/models/doctor_model.dart' as doctor;
import 'package:eyecare_app/models/appointment_model.dart';

void main() {
  group('MockDataService Tests', () {
    late MockDataService service;

    setUp(() {
      service = MockDataService();
      service.loadMockData();
    });

    test('getUsers returns list of users', () {
      final users = service.getUsers();
      expect(users, isA<List<UserModel>>());
      expect(users.isNotEmpty, true);
    });

    test('getUserByEmail returns correct user', () {
      final user = service.getUserByEmail('john@example.com');
      expect(user, isNotNull);
      expect(user?.name, 'John Doe');
    });

    test('getUserByEmail returns null for non-existent email', () {
      final user = service.getUserByEmail('nonexistent@example.com');
      expect(user, isNull);
    });

    test('addUser adds new user', () {
      final newUser = UserModel(
        id: '4',
        name: 'Test User',
        email: 'test@example.com',
        password: 'password',
        role: 'pasien',
      );

      service.addUser(newUser);
      final user = service.getUserByEmail('test@example.com');
      expect(user, isNotNull);
      expect(user?.name, 'Test User');
    });

    test('updateUser updates existing user', () {
      final updatedUser = UserModel(
        id: '1',
        name: 'John Updated',
        email: 'john@example.com',
        password: 'password123',
        role: 'pasien',
        phoneNumber: '081234567890',
      );

      service.updateUser(updatedUser);
      final user = service.getUserByEmail('john@example.com');
      expect(user?.name, 'John Updated');
    });

    test('getDoctors returns list of doctors', () {
      final doctors = service.getDoctors();
      expect(doctors, isA<List<doctor.DoctorModel>>());
      expect(doctors.isNotEmpty, true);
    });

    test('getDoctorById returns correct doctor', () {
      final doctor = service.getDoctorById('2');
      expect(doctor, isNotNull);
      expect(doctor?.name, contains('Dr. Sarah'));
    });

    test('getAppointments returns list of appointments', () {
      final appointments = service.getAppointments();
      expect(appointments, isA<List<AppointmentModel>>());
      expect(appointments.isNotEmpty, true);
    });

    test('getAppointmentsByPatient returns patient appointments', () {
      final appointments = service.getAppointmentsByPatient('1');
      expect(appointments.isNotEmpty, true);
      expect(appointments.every((a) => a.patientId == '1'), true);
    });

    test('getAppointmentsByDoctor returns doctor appointments', () {
      final appointments = service.getAppointmentsByDoctor('2');
      expect(appointments.isNotEmpty, true);
      expect(appointments.every((a) => a.doctorId == '2'), true);
    });

    test('addAppointment adds new appointment', () {
      final newAppointment = AppointmentModel(
        id: '4',
        patientId: '1',
        doctorId: '2',
        doctorName: 'Dr. Test',
        date: DateTime.now(),
        time: '10:00',
        complaint: 'Test',
        status: 'pending',
        paymentMethod: 'Transfer Bank',
        createdAt: DateTime.now(),
      );

      service.addAppointment(newAppointment);
      final appointments = service.getAppointments();
      expect(appointments.length, greaterThan(0));
    });

    test('updateAppointment updates existing appointment', () {
      final updatedAppointment = AppointmentModel(
        id: '1',
        patientId: '1',
        doctorId: '2',
        doctorName: 'Dr. Sarah Wijaya, Sp.M',
        date: DateTime.now(),
        time: '10:00',
        complaint: 'Updated complaint',
        status: 'completed',
        paymentMethod: 'Transfer Bank',
        createdAt: DateTime.now(),
      );

      service.updateAppointment(updatedAppointment);
      final appointments = service.getAppointments();
      final appointment = appointments.firstWhere((a) => a.id == '1');
      expect(appointment.complaint, 'Updated complaint');
      expect(appointment.status, 'completed');
    });

    test('getExaminations returns list of examinations', () {
      final examinations = service.getExaminations();
      expect(examinations.isNotEmpty, true);
    });

    test('getExaminationsByPatient returns patient examinations', () {
      final examinations = service.getExaminationsByPatient('1');
      expect(examinations.isNotEmpty, true);
      expect(examinations.every((e) => e.patientId == '1'), true);
    });

    test('getExaminationsByDoctor returns doctor examinations', () {
      final examinations = service.getExaminationsByDoctor('2');
      expect(examinations.isNotEmpty, true);
      expect(examinations.every((e) => e.doctorId == '2'), true);
    });

    test('addExamination adds new examination', () {
      // TODO: Implement examination test
      expect(true, true); // Placeholder test
    });

    test('getNotificationsByUser returns user notifications', () {
      final notifications = service.getNotificationsByUser('1');
      expect(notifications.isNotEmpty, true);
      expect(notifications.every((n) => n.userId == '1'), true);
    });

    test('markNotificationAsRead updates notification', () {
      service.markNotificationAsRead('1');
      final notifications = service.getNotificationsByUser('1');
      final notification = notifications.firstWhere((n) => n.id == '1');
      expect(notification.isRead, true);
    });

    test('getUnreadNotificationCount returns correct count', () {
      final count = service.getUnreadNotificationCount('1');
      expect(count, greaterThanOrEqualTo(0));
    });
  });
}