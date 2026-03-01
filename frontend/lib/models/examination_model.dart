import 'package:flutter/material.dart';

class ExaminationModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime examinationDate;
  final String fundusPhotoUrl;
  final String prediction; // 'Glaukoma' or 'Normal'
  final double confidenceScore;
  final String? gradCamHeatmap;
  final String? doctorDiagnosis;
  final String? doctorRecommendation;
  final String status; // 'pending', 'completed'

  ExaminationModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.examinationDate,
    required this.fundusPhotoUrl,
    required this.prediction,
    required this.confidenceScore,
    this.gradCamHeatmap,
    this.doctorDiagnosis,
    this.doctorRecommendation,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'examinationDate': examinationDate.toIso8601String(),
      'fundusPhotoUrl': fundusPhotoUrl,
      'prediction': prediction,
      'confidenceScore': confidenceScore,
      'gradCamHeatmap': gradCamHeatmap,
      'doctorDiagnosis': doctorDiagnosis,
      'doctorRecommendation': doctorRecommendation,
      'status': status,
    };
  }

  factory ExaminationModel.fromJson(Map<String, dynamic> json) {
    return ExaminationModel(
      id: json['id'],
      appointmentId: json['appointmentId'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      examinationDate: DateTime.parse(json['examinationDate']),
      fundusPhotoUrl: json['fundusPhotoUrl'],
      prediction: json['prediction'],
      confidenceScore: json['confidenceScore'],
      gradCamHeatmap: json['gradCamHeatmap'],
      doctorDiagnosis: json['doctorDiagnosis'],
      doctorRecommendation: json['doctorRecommendation'],
      status: json['status'],
    );
  }

  Color get predictionColor {
    return prediction == 'Glaukoma' ? Colors.red : Colors.green;
  }
}