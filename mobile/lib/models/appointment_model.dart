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

  // Additional fields from API response
  final String? invoiceNumber;
  final String? paymentStatus;
  final String? amount;
  final String? doctorNotes;
  final String? confirmedBy;
  final DateTime? confirmedAt;

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
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'time': time,
      'complaint': complaint,
      'status': status,
      'rejectionReason': rejectionReason,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'invoiceNumber': invoiceNumber,
      'paymentStatus': paymentStatus,
      'amount': amount,
      'doctorNotes': doctorNotes,
      'confirmedBy': confirmedBy,
      'confirmedAt': confirmedAt?.toIso8601String(),
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Handle different date formats
    DateTime parseDate(String dateStr) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        // Handle format like "2026-04-14 16:47:57"
        return DateTime.parse(dateStr.replaceFirst(' ', 'T'));
      }
    }

    return AppointmentModel(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      patientName: json['patient_name'],
      doctorId: json['doctor_id'].toString(),
      doctorName: json['doctor_name'] ?? '',
      date: json['appointment_date'] != null
          ? parseDate(json['appointment_date'])
          : DateTime.now(),
      time: json['appointment_time'] ?? json['time_slot'] ?? '',
      complaint: json['patient_complaint'] ?? json['complaint'] ?? '',
      status: json['appointment_status'] ?? json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      paymentMethod: json['payment_method'] ?? 'Transfer Bank',
      createdAt: json['created_at'] != null
          ? parseDate(json['created_at'])
          : DateTime.now(),
      invoiceNumber: json['invoice_number'],
      paymentStatus: json['payment_status'],
      amount: json['amount'],
      doctorNotes: json['doctor_notes'],
      confirmedBy: json['confirmed_by'],
      confirmedAt: json['confirmed_at'] != null ? parseDate(json['confirmed_at']) : null,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'rejected':
        return 'Ditolak';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get formattedAmount {
    if (amount == null) return 'Rp 0';
    try {
      final number = double.parse(amount!);
      final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
      return formatter.format(number);
    } catch (e) {
      return 'Rp ${amount ?? 0}';
    }
  }

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'unpaid':
        return 'Belum Dibayar';
      case 'paid':
        return 'Sudah Dibayar';
      case 'pending':
        return 'Menunggu Verifikasi';
      default:
        return paymentStatus ?? '-';
    }
  }

  Color getAppointmentStatusColor(String status) {
    switch (status) {
      case 'pending_payment':
        return Colors.orange;
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
