import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/examination_model.dart';

class ExaminationDetailScreen extends StatelessWidget {
  final ExaminationModel examination;

  const ExaminationDetailScreen({super.key, required this.examination});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hasil Pemeriksaan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: examination.prediction == 'Glaukoma'
                    ? Colors.red.withValues(alpha: 0.05)
                    : Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: examination.prediction == 'Glaukoma'
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.green.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Result Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: examination.prediction == 'Glaukoma'
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      examination.prediction == 'Glaukoma'
                          ? Icons.warning
                          : Icons.check_circle,
                      size: 40,
                      color: examination.prediction == 'Glaukoma'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prediction
                  Text(
                    examination.prediction,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: examination.prediction == 'Glaukoma'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Confidence Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Confidence: ${(examination.confidenceScore * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fundus Photo
            Text(
              'Foto Fundus',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(examination.fundusPhotoUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Handle image error
                  },
                ),
              ),
              child: examination.fundusPhotoUrl.isEmpty
                  ? Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey[400],
                ),
              )
                  : null,
            ),
            const SizedBox(height: 24),

            // Grad-CAM Heatmap (if available)
            if (examination.gradCamHeatmap != null) ...[
              Text(
                'Heatmap Grad-CAM',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(examination.gradCamHeatmap!),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Handle image error
                    },
                  ),
                ),
                child: examination.gradCamHeatmap!.isEmpty
                    ? Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                )
                    : null,
              ),
              const SizedBox(height: 24),
            ],

            // Doctor Diagnosis
            if (examination.doctorDiagnosis != null) ...[
              Text(
                'Diagnosis Dokter',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  examination.doctorDiagnosis!,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Doctor Recommendation
            if (examination.doctorRecommendation != null) ...[
              Text(
                'Rekomendasi Dokter',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF4A90E2).withValues(alpha: 0.3)),
                ),
                child: Text(
                  examination.doctorRecommendation!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF4A90E2),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Examination Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Dokter',
                    examination.doctorName,
                    Icons.person,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Tanggal',
                    dateFormat.format(examination.examinationDate),
                    Icons.calendar_today,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Status',
                    examination.status == 'completed' ? 'Selesai' : 'Menunggu',
                    Icons.info,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}