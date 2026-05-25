import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';

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
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    
    // ✅ Load data untuk dokter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      
      if (authProvider.isDokter) {
        appointmentProvider.loadDoctorAppointments();
      }
    });
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
        title: Text('Janji Masuk', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dikonfirmasi'),
            Tab(text: 'Selesai'),
          ],
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4A90E2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppointmentProvider>().loadDoctorAppointments();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
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
            .toList();

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  status == 'confirmed' ? 'Tidak ada janji dikonfirmasi' : 'Tidak ada janji selesai',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadDoctorAppointments(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildAppointmentCard(appointment);
            },
          ),
        );
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final dateFormat = DateFormat('dd MMM yyyy');

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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person, color: Color(0xFF4A90E2)),
        ),
        title: Text(
          appointment.patientName ?? 'Pasien',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dateFormat.format(appointment.date),
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            if (appointment.resultLabel != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  appointment.resultLabel!,
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue),
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: appointment.getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            appointment.statusDisplay,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: appointment.getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}