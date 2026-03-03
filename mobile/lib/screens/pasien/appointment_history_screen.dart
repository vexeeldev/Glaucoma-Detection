import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/appointment_card.dart';
import 'examination_detail_screen.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Semua';

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

  List<String> get filterOptions => ['Semua', 'Aktif', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Janji',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Janji Temu'),
            Tab(text: 'Pemeriksaan'),
          ],
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4A90E2),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Appointments Tab
          _buildAppointmentsTab(),
          // Examinations Tab
          _buildExaminationsTab(),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF4A90E2).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF4A90E2),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Appointments List
        Expanded(
          child: Consumer<AppointmentProvider>(
            builder: (context, provider, child) {
              var appointments = provider.appointments;

              // Filter appointments
              if (_selectedFilter == 'Aktif') {
                appointments = appointments.where((apt) =>
                apt.status == 'pending' ||
                    apt.status == 'paid' ||
                    apt.status == 'confirmed'
                ).toList();
              } else if (_selectedFilter == 'Selesai') {
                appointments = appointments.where((apt) =>
                apt.status == 'completed' ||
                    apt.status == 'rejected' ||
                    apt.status == 'cancelled'
                ).toList();
              }

              // Sort by date (newest first)
              appointments.sort((a, b) => b.date.compareTo(a.date));

              if (appointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada riwayat janji',
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
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return AppointmentCard(
                    appointment: appointment,
                    showActions: true,
                    onCancel: appointment.status == 'pending' ||
                        appointment.status == 'paid' ||
                        appointment.status == 'confirmed'
                        ? () => _showCancelDialog(appointment.id)
                        : null,
                    onTap: () {
                      // Navigate to appointment detail
                      _showAppointmentDetail(appointment);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExaminationsTab() {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        final examinations = provider.examinations;

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
                  'Belum ada pemeriksaan',
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
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: examination.prediction == 'Glaukoma'
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    color: examination.prediction == 'Glaukoma'
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                title: Text(
                  examination.doctorName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal: ${DateFormat('dd MMM yyyy').format(examination.examinationDate)}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
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
                        examination.prediction,
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
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExaminationDetailScreen(
                        examination: examination,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showAppointmentDetail(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Janji'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dokter: ${appointment.doctorName}'),
              const SizedBox(height: 8),
              Text('Tanggal: ${DateFormat('dd MMM yyyy').format(appointment.date)}'),
              const SizedBox(height: 8),
              Text('Jam: ${appointment.time}'),
              const SizedBox(height: 8),
              Text('Keluhan: ${appointment.complaint}'),
              const SizedBox(height: 8),
              Text('Status: ${_getStatusDisplay(appointment.status)}'),
              if (appointment.rejectionReason != null) ...[
                const SizedBox(height: 8),
                Text('Alasan: ${appointment.rejectionReason}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  void _showCancelDialog(String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Janji'),
          content: const Text('Apakah Anda yakin ingin membatalkan janji ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // Simpan mounted state sebelum async
                final mountedAfterPop = mounted;

                if (!mountedAfterPop) return;

                final provider = Provider.of<AppointmentProvider>(
                  context,
                  listen: false,
                );

                final success = await provider.cancelAppointment(appointmentId);

                // Cek mounted lagi setelah async
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Janji berhasil dibatalkan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }
}