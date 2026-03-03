import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/examination_model.dart';
import '../../providers/appointment_provider.dart';
import 'examination_detail_dokter_screen.dart';

class ExaminationListScreen extends StatefulWidget {
  const ExaminationListScreen({super.key});

  @override
  State<ExaminationListScreen> createState() => _ExaminationListScreenState();
}

class _ExaminationListScreenState extends State<ExaminationListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pemeriksaan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Selesai'),
          ],
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4A90E2),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExaminationList('pending'),
          _buildExaminationList('completed'),
        ],
      ),
    );
  }

  Widget _buildExaminationList(String status) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        final examinations = provider.examinations
            .where((exam) => exam.status == status)
            .toList()
          ..sort((a, b) => b.examinationDate.compareTo(a.examinationDate));

        if (examinations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  status == 'pending'
                      ? 'Tidak ada pemeriksaan menunggu'
                      : 'Belum ada pemeriksaan selesai',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: examinations.length,
          itemBuilder: (context, index) {
            final examination = examinations[index];
            return _buildExaminationCard(examination);
          },
        );
      },
    );
  }

  Widget _buildExaminationCard(ExaminationModel examination) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExaminationDetailDokterScreen(
              examination: examination,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: examination.status == 'pending'
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  examination.status == 'pending'
                      ? Icons.pending
                      : Icons.check_circle,
                  color: examination.status == 'pending'
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
              title: Text(
                examination.patientName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(examination.examinationDate),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  if (examination.prediction.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: examination.prediction == 'Glaukoma'
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'AI: ${examination.prediction} (${(examination.confidenceScore * 100).toStringAsFixed(1)}%)',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: examination.prediction == 'Glaukoma'
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: examination.status == 'pending'
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  examination.status == 'pending' ? 'Menunggu' : 'Selesai',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: examination.status == 'pending'
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (examination.status == 'pending')
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExaminationDetailDokterScreen(
                                examination: examination,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Mulai Pemeriksaan'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}