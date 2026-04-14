import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/doctor_model.dart';
import '../../providers/doctor_provider.dart';
import 'book_appointment_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final int doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  bool _isLoading = true;
  bool _isAvailableToday = false;
  DoctorModel? _doctor;

  @override
  void initState() {
    super.initState();
    _loadDoctorDetail();
  }

  Future<void> _loadDoctorDetail() async {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    final doctor = await doctorProvider.loadDoctorDetail(widget.doctorId);

    debugPrint('Doctor data loaded: ${doctor?.name}');
    debugPrint('Schedules count: ${doctor?.schedules?.length}');

    if (doctor?.schedules != null) {
      for (var schedule in doctor!.schedules!) {
        debugPrint('Schedule: ${schedule.dayName}, Max Patients: ${schedule.maxPatients}');
      }
    }

    // Cek ketersediaan hari ini menggunakan API schedules
    final isAvailable = await doctorProvider.checkDoctorAvailabilityToday(
        widget.doctorId,
        DateTime.now()
    );

    setState(() {
      _doctor = doctor;
      _isAvailableToday = isAvailable;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_doctor == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat detail dokter',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDoctorDetail,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Dokter',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorHeader(),
            const SizedBox(height: 24),
            _buildDoctorInfo(),
            const SizedBox(height: 24),
            _buildTodayAvailabilitySection(),
            const SizedBox(height: 24),
            _buildScheduleSection(),
            const SizedBox(height: 32),
            _buildBookButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorHeader() {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: _doctor!.profilePhoto != null && _doctor!.profilePhoto!.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              _doctor!.profilePhoto!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFF4A90E2),
                );
              },
            ),
          )
              : const Icon(
            Icons.person,
            size: 50,
            color: Color(0xFF4A90E2),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _doctor!.name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _doctor!.specialization,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF4A90E2),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isAvailableToday
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isAvailableToday ? 'Tersedia Hari Ini' : 'Tidak Tersedia Hari Ini',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _isAvailableToday ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Dokter',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Spesialis', _doctor!.specialization),
          const SizedBox(height: 8),
          _buildInfoRow('Email', _doctor!.email ?? '-'),
          const SizedBox(height: 8),
          _buildInfoRow('Biaya Konsultasi', _formatCurrency(_doctor!.consultationFee ?? '0')),
          if (_doctor!.biography != null && _doctor!.biography!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Biografi', _doctor!.biography!, isMultiline: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // SECTION BARU: Menampilkan jadwal yang tersedia hari ini
  Widget _buildTodayAvailabilitySection() {
    return Consumer<DoctorProvider>(
      builder: (context, provider, child) {
        if (provider.isCheckingAvailability) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (provider.availableSlots.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.access_time, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada jadwal praktik hari ini',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.today, size: 20, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Jadwal Praktik Hari Ini',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...provider.availableSlots.map((slot) => _buildTodaySlotCard(slot)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodaySlotCard(AvailableSlot slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.access_time,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.time,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Kuota: ${slot.remaining}/${slot.maxPatients} tersisa',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: slot.remaining > 0 ? Colors.green[600] : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: slot.status == 'Buka'
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              slot.status,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: slot.status == 'Buka' ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    if (_doctor!.schedules == null || _doctor!.schedules!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Belum ada jadwal praktik',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    // Urutkan jadwal berdasarkan hari
    final orderedSchedules = _doctor!.schedules!.toList()
      ..sort((a, b) {
        const order = {
          'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
          'friday': 5, 'saturday': 6, 'sunday': 7
        };
        return (order[a.dayOfWeek.toLowerCase()] ?? 0)
            .compareTo(order[b.dayOfWeek.toLowerCase()] ?? 0);
      });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semua Jadwal Praktik',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...orderedSchedules.map((schedule) => _buildScheduleCard(schedule)),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.schedule,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.dayName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.timeRange,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Kuota: ${schedule.maxPatients} pasien',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: schedule.isAvailable
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              schedule.isAvailable ? 'Tersedia' : 'Penuh',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: schedule.isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isAvailableToday
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookAppointmentScreen(doctor: _doctor!),
            ),
          );
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _isAvailableToday ? 'Buat Janji' : 'Tidak Tersedia Hari Ini',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatCurrency(String amount) {
    try {
      final number = double.parse(amount);
      return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(number);
    } catch (e) {
      return amount;
    }
  }
}