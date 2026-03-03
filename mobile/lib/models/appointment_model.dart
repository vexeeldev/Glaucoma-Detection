import 'package:flutter/material.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String time;
  final String complaint;
  final String status; // pending, paid, confirmed, rejected, completed, cancelled
  final String? rejectionReason;
  final String paymentMethod;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.complaint,
    required this.status,
    this.rejectionReason,
    required this.paymentMethod,
    required this.createdAt,
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
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      complaint: json['complaint'],
      status: json['status'],
      rejectionReason: json['rejectionReason'],
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get statusDisplay {
    switch (status) {
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

  Color getAppointmentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}