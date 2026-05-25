import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String? patientName;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String time;
  final String complaint;
  String status;
  String? rejectionReason;
  final String paymentMethod;
  final DateTime createdAt;
  final String? invoiceNumber;
  final String? paymentStatus;
  final String? amount;
  final String? doctorNotes;
  final String? confirmedBy;
  final DateTime? confirmedAt;
  final String? resultLabel; // ✅ Tambahkan ini

  AppointmentModel({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.complaint,
    required this.status,
    this.rejectionReason,
    required this.paymentMethod,
    required this.createdAt,
    this.invoiceNumber,
    this.paymentStatus,
    this.amount,
    this.doctorNotes,
    this.confirmedBy,
    this.confirmedAt,
    this.resultLabel,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Handle format dari endpoint dokter (/api/mobile/doctor/appointments)
    if (json.containsKey('patient_name') && json.containsKey('appointment_date')) {
      return AppointmentModel(
        id: json['id'].toString(),
        patientId: '0',
        patientName: json['patient_name'] ?? 'Pasien',
        doctorId: '0',
        doctorName: 'Dokter',
        date: DateTime.parse(json['appointment_date']),
        time: '',
        complaint: '',
        status: json['status'] ?? 'pending',
        rejectionReason: null,
        paymentMethod: 'Transfer Bank',
        createdAt: DateTime.now(),
        resultLabel: json['result_label'],
      );
    }
    
    // Handle format dari endpoint pasien
    DateTime parseDate(String dateStr) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime.parse(dateStr.replaceFirst(' ', 'T'));
      }
    }

    return AppointmentModel(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      patientName: json['patient_name'],
      doctorId: json['doctor_id'].toString(),
      doctorName: json['doctor_name'] ?? '',
      date: json['appointment_date'] != null ? parseDate(json['appointment_date']) : DateTime.now(),
      time: json['appointment_time'] ?? json['time_slot'] ?? '',
      complaint: json['patient_complaint'] ?? json['complaint'] ?? '',
      status: json['appointment_status'] ?? json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      paymentMethod: json['payment_method'] ?? 'Transfer Bank',
      createdAt: json['created_at'] != null ? parseDate(json['created_at']) : DateTime.now(),
      invoiceNumber: json['invoice_number'],
      paymentStatus: json['payment_status'],
      amount: json['amount'],
      doctorNotes: json['doctor_notes'],
      confirmedBy: json['confirmed_by'],
      confirmedAt: json['confirmed_at'] != null ? parseDate(json['confirmed_at']) : null,
      resultLabel: json['result_label'],
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending_payment': return 'Menunggu Pembayaran';
      case 'pending': return 'Menunggu Pembayaran';
      case 'paid': return 'Menunggu Konfirmasi';
      case 'confirmed': return 'Dikonfirmasi';
      case 'rejected': return 'Ditolak';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 'pending_payment': return Colors.orange;
      case 'pending': return Colors.orange;
      case 'paid': return Colors.blue;
      case 'confirmed': return Colors.green;
      case 'rejected': return Colors.red;
      case 'completed': return Colors.teal;
      case 'cancelled': return Colors.grey;
      default: return Colors.grey;
    }
  }
}