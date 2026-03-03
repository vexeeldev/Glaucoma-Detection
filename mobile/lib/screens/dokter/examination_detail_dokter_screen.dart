import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/examination_model.dart';
import '../../models/notification_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/notification_provider.dart';

class ExaminationDetailDokterScreen extends StatefulWidget {
  final AppointmentModel? appointment;
  final ExaminationModel? examination;

  const ExaminationDetailDokterScreen({
    super.key,
    this.appointment,
    this.examination,
  });

  @override
  State<ExaminationDetailDokterScreen> createState() =>
      _ExaminationDetailDokterScreenState();
}

class _ExaminationDetailDokterScreenState
    extends State<ExaminationDetailDokterScreen> {
  late TextEditingController _diagnosisController;
  late TextEditingController _recommendationController;
  bool _isLoading = false;

  // Simpan provider references
  late AppointmentProvider _appointmentProvider;
  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    super.initState();
    _diagnosisController = TextEditingController(
      text: widget.examination?.doctorDiagnosis ?? '',
    );
    _recommendationController = TextEditingController(
      text: widget.examination?.doctorRecommendation ?? '',
    );

    // Ambil provider references di initState
    _appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    _notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  Future<void> _saveExamination() async {
    if (!mounted) return;

    if (_diagnosisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diagnosis harus diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      ExaminationModel examination;

      if (widget.examination != null) {
        // Update existing examination
        examination = ExaminationModel(
          id: widget.examination!.id,
          appointmentId: widget.examination!.appointmentId,
          patientId: widget.examination!.patientId,
          patientName: widget.examination!.patientName,
          doctorId: widget.examination!.doctorId,
          doctorName: widget.examination!.doctorName,
          examinationDate: widget.examination!.examinationDate,
          fundusPhotoUrl: widget.examination!.fundusPhotoUrl,
          prediction: widget.examination!.prediction,
          confidenceScore: widget.examination!.confidenceScore,
          gradCamHeatmap: widget.examination!.gradCamHeatmap,
          doctorDiagnosis: _diagnosisController.text,
          doctorRecommendation: _recommendationController.text.isEmpty
              ? null
              : _recommendationController.text,
          status: 'completed',
        );
      } else {
        // Create new examination (in real app, would get from ML service)
        examination = ExaminationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          appointmentId: widget.appointment!.id,
          patientId: widget.appointment!.patientId,
          patientName: 'Pasien ${widget.appointment!.patientId}',
          doctorId: widget.appointment!.doctorId,
          doctorName: widget.appointment!.doctorName,
          examinationDate: DateTime.now(),
          fundusPhotoUrl: 'assets/images/fundus_placeholder.jpg',
          prediction: 'Normal', // This would come from ML
          confidenceScore: 0.95,
          doctorDiagnosis: _diagnosisController.text,
          doctorRecommendation: _recommendationController.text.isEmpty
              ? null
              : _recommendationController.text,
          status: 'completed',
        );
      }

      // Gunakan provider references yang sudah disimpan
      await _appointmentProvider.updateExamination(examination);

      // Update appointment status to completed
      if (widget.appointment != null) {
        await _appointmentProvider.updateAppointmentStatus(widget.appointment!.id, 'completed');
      }

      // Create notification for patient using saved provider reference
      _notificationProvider.addNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: examination.patientId,
          title: 'Hasil Pemeriksaan Tersedia',
          message: 'Hasil pemeriksaan Anda dengan ${examination.doctorName} sudah tersedia',
          type: 'examination_ready',
          isRead: false,
          createdAt: DateTime.now(),
          data: {'examinationId': examination.id},
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemeriksaan berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final examination = widget.examination;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Pemeriksaan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (examination?.status != 'completed')
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveExamination,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          examination?.patientName ??
                              'Pasien ${widget.appointment?.patientId}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Dokter: ${examination?.doctorName ?? widget.appointment?.doctorName}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Tanggal: ${dateFormat.format(examination?.examinationDate ?? widget.appointment?.date ?? DateTime.now())}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Result (if available)
            if (examination != null) ...[
              Text(
                'Hasil AI',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: examination.prediction == 'Glaukoma'
                      ? Colors.red.withValues(alpha: 0.05)
                      : Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: examination.prediction == 'Glaukoma'
                        ? Colors.red.withValues(alpha: 0.3)
                        : Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Prediksi:',
                          style: GoogleFonts.poppins(),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: examination.prediction == 'Glaukoma'
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            examination.prediction,
                            style: GoogleFonts.poppins(
                              color: examination.prediction == 'Glaukoma'
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Confidence:',
                          style: GoogleFonts.poppins(),
                        ),
                        Text(
                          '${(examination.confidenceScore * 100).toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

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
                image: examination?.fundusPhotoUrl != null
                    ? DecorationImage(
                  image: AssetImage(examination!.fundusPhotoUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                )
                    : null,
              ),
              child: examination?.fundusPhotoUrl == null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Foto belum tersedia',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : null,
            ),
            const SizedBox(height: 24),

            // Diagnosis
            Text(
              'Diagnosis Dokter',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _diagnosisController,
              maxLines: 4,
              enabled: examination?.status != 'completed',
              decoration: InputDecoration(
                hintText: 'Masukkan diagnosis...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: examination?.status == 'completed'
                    ? Colors.grey[100]
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Recommendation
            Text(
              'Rekomendasi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _recommendationController,
              maxLines: 3,
              enabled: examination?.status != 'completed',
              decoration: InputDecoration(
                hintText: 'Masukkan rekomendasi...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: examination?.status == 'completed'
                    ? Colors.grey[100]
                    : Colors.white,
              ),
            ),

            if (examination?.status != 'completed') ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveExamination,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Simpan Pemeriksaan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}