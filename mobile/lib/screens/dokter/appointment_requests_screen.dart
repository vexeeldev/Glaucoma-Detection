import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/notification_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/mock_data_service.dart';
import 'examination_detail_dokter_screen.dart';

class AppointmentRequestsScreen extends StatefulWidget {
  final int? initialTab;

  const AppointmentRequestsScreen({super.key, this.initialTab});

  @override
  State<AppointmentRequestsScreen> createState() => _AppointmentRequestsScreenState();
}

class _AppointmentRequestsScreenState extends State<AppointmentRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method untuk mendapatkan warna status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  // Method untuk mendapatkan teks status
  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
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

  // Method untuk mendapatkan nama pasien
  Future<String> _getPatientName(String patientId) async {
    final mockDataService = MockDataService();
    final user = mockDataService.getUserById(patientId);
    return user?.name ?? 'Pasien $patientId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Janji Masuk',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Dikonfirmasi'),
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
          _buildAppointmentList('paid'),
          _buildAppointmentList('confirmed'),
          _buildAppointmentList('completed'),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        final appointments = provider.appointments
            .where((apt) => apt.status == status)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada janji',
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
            return FutureBuilder<String>(
              future: _getPatientName(appointment.patientId),
              builder: (context, snapshot) {
                final patientName = snapshot.data ?? 'Pasien ${appointment.patientId}';
                return _buildAppointmentCard(appointment, status, patientName);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(
      AppointmentModel appointment,
      String status,
      String patientName
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF4A90E2),
              ),
            ),
            title: Text(
              patientName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(appointment.date),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keluhan: ${appointment.complaint}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusDisplay(status),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (status == 'paid')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectDialog(appointment),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmAppointment(appointment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Konfirmasi'),
                    ),
                  ),
                ],
              ),
            ),
          if (status == 'confirmed')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _viewPatientDetail(appointment, patientName),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Lihat Detail'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _startExamination(appointment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Periksa'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showRejectDialog(AppointmentModel appointment) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tolak Janji'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Alasan penolakan:'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alasan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.isNotEmpty) {
                  _rejectAppointment(appointment, reasonController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );
  }

  void _confirmAppointment(AppointmentModel appointment) async {
    final appointmentProvider = context.read<AppointmentProvider>();
    final notifProvider = context.read<NotificationProvider>();

    await appointmentProvider.updateAppointmentStatus(
      appointment.id,
      'confirmed',
    );

    if (!mounted) return;

    notifProvider.addNotification(
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: appointment.patientId,
        title: 'Janji Dikonfirmasi',
        message: 'Janji Anda dengan ${appointment.doctorName} telah dikonfirmasi',
        type: 'appointment_confirmed',
        isRead: false,
        createdAt: DateTime.now(),
        data: {'appointmentId': appointment.id},
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Janji berhasil dikonfirmasi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _rejectAppointment(
      AppointmentModel appointment,
      String reason,
      ) async {
    final appointmentProvider = context.read<AppointmentProvider>();
    final notifProvider = context.read<NotificationProvider>();

    await appointmentProvider.updateAppointmentStatus(
      appointment.id,
      'rejected',
      rejectionReason: reason,
    );

    if (!mounted) return;

    notifProvider.addNotification(
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: appointment.patientId,
        title: 'Janji Ditolak',
        message:
        'Janji Anda dengan ${appointment.doctorName} ditolak. Alasan: $reason',
        type: 'appointment_rejected',
        isRead: false,
        createdAt: DateTime.now(),
        data: {'appointmentId': appointment.id},
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Janji ditolak'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _viewPatientDetail(AppointmentModel appointment, String patientName) {
    // Navigate to patient detail
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Pasien'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama: $patientName'),
              const SizedBox(height: 8),
              Text('Keluhan: ${appointment.complaint}'),
              const SizedBox(height: 8),
              Text('Tanggal: ${DateFormat('dd MMM yyyy').format(appointment.date)}'),
              const SizedBox(height: 8),
              Text('Jam: ${appointment.time}'),
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

  void _startExamination(AppointmentModel appointment) {
    // Navigate to examination screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExaminationDetailDokterScreen(
          appointment: appointment,
        ),
      ),
    );
  }
}