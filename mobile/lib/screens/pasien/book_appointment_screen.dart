import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/doctor_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';

class BookAppointmentScreen extends StatefulWidget {
  final DoctorModel doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final ApiService _apiService = ApiService();

  // Data dari provider
  List<AvailableSlot> _availableSlots = [];

  // Selected values
  String? _selectedTime;
  String _selectedPackage = 'basic';
  final TextEditingController _complaintController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;

  late AuthProvider _authProvider;

  // Package options
  final Map<String, PackageInfo> _packages = {
    'basic': PackageInfo(
      name: 'Paket Basic',
      price: 150000,
      description: 'Konsultasi + Tonometri',
    ),
    'screening': PackageInfo(
      name: 'Paket Screening',
      price: 500000,
      description: 'Dasar + GlaucoScan AI Skrining',
    ),
    'complete': PackageInfo(
      name: 'Paket Complete',
      price: 1200000,
      description: 'Full OCT + Perimetri',
    ),
  };

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);

      if (doctorProvider.availableSlots.isNotEmpty) {
        _availableSlots = List.from(doctorProvider.availableSlots);
      } else {
        await doctorProvider.checkDoctorAvailabilityToday(
            widget.doctor.id,
            DateTime.now()
        );
        _availableSlots = List.from(doctorProvider.availableSlots);
      }

      debugPrint('Available slots loaded: ${_availableSlots.length}');
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error loading available slots: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat jadwal: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  
  Future<void> _bookAppointment() async {
  // Validasi 1: Waktu dipilih
  if (_selectedTime == null) {
    _showSnackbar('Pilih jam temu', Colors.orange);
    return;
  }

  // Validasi 2: Keluhan tidak kosong
  if (_complaintController.text.isEmpty) {
    _showSnackbar('Masukkan keluhan', Colors.orange);
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    // Validasi 3: Patient ID valid
    final patientId = _authProvider.currentUser?.id;
    if (patientId == null) {
      _showSnackbar('Data user tidak ditemukan', Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }

    int parsedPatientId;
    try {
      parsedPatientId = int.parse(patientId);
    } catch (e) {
      _showSnackbar('ID user tidak valid', Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }

    // Validasi 4: Format waktu
    String formattedTime = _selectedTime!;
    if (formattedTime.contains(' - ')) {
      formattedTime = formattedTime.split(' - ')[0].trim();
    }
    // Tambahkan detik jika perlu
    if (formattedTime.split(':').length == 2) {
      formattedTime = '$formattedTime:00';
    }
    debugPrint('⏰ Formatted time: $formattedTime');

    // Validasi 5: Tanggal
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today);
    
    // Cek apakah waktu masih available (opsional, tergantung API)
    final timeParts = formattedTime.split(':');
    if (timeParts.length >= 2) {
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final selectedDateTime = DateTime(today.year, today.month, today.day, hour, minute);
      if (selectedDateTime.isBefore(DateTime.now())) {
        _showSnackbar('Waktu yang dipilih sudah lewat', Colors.orange);
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final requestData = {
      'patient_id': parsedPatientId,
      'doctor_id': widget.doctor.id,
      'appointment_date': formattedDate,
      'appointment_time': formattedTime,
      'package_type': _selectedPackage,
      'patient_complaint': _complaintController.text,
    };

    debugPrint('📤 Booking request: $requestData');

    final response = await _apiService.post(
      ApiService.patientBooking,
      requestData,
    );

    debugPrint('📥 Booking response: $response');

    if (!mounted) return;

    // ✅ PERBAIKAN: Cek BOTH status dan success
    if (response['status'] == 'success' || response['success'] == true) {
      final data = response['data'];
      if (mounted) {
        _showSuccessDialog(
          invoiceNumber: data?['invoice'] ?? 'N/A',
          totalAmount: data?['total_amount'] ?? 0,
          package: response['data']?['package'] ?? _selectedPackage,
        );
      }
    } else {
      String errorMessage = response['message'] ?? 'Booking gagal';
      
      // ✅ PERBAIKAN: Handle berbagai format errors
      if (response['errors'] != null) {
        if (response['errors'] is Map) {
          final errors = response['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.join(', ');
        } else if (response['errors'] is List) {
          errorMessage = (response['errors'] as List).join(', ');
        } else {
          errorMessage = response['errors'].toString();
        }
      }
      _showSnackbar(errorMessage, Colors.red);
    }
  } catch (e) {
    if (!mounted) return;
    debugPrint('❌ Booking error: $e');
    _showSnackbar('Terjadi kesalahan: ${e.toString()}', Colors.red);
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showSuccessDialog({required String invoiceNumber, required int totalAmount, required String package}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Booking Berhasil!',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('Invoice: $invoiceNumber', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Paket: ${_packages[package]?.name ?? package}'),
                    Text('Total: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(totalAmount)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Silakan lanjutkan ke pembayaran',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Janji Temu', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorInfo(),
            const SizedBox(height: 24),
            _buildTimeSelection(),
            const SizedBox(height: 24),
            _buildPackageSelection(),
            const SizedBox(height: 24),
            _buildComplaintField(),
            const SizedBox(height: 24),
            _buildTotalPrice(),
            const SizedBox(height: 24),
            _buildBookButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person, size: 30, color: Color(0xFF4A90E2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctor.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(widget.doctor.specialization, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF4A90E2))),
                if (widget.doctor.consultationFee != null)
                  Text('Biaya Konsultasi: ${_formatCurrency(widget.doctor.consultationFee!)}',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.access_time, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Tidak ada jadwal tersedia hari ini',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Jam Temu', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._availableSlots.map((slot) => _buildTimeCard(slot)),
      ],
    );
  }

  Widget _buildTimeCard(AvailableSlot slot) {
    final isSelected = _selectedTime == slot.time;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTime = slot.time;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFF4A90E2).withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF4A90E2) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.time,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF4A90E2) : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Kuota: ${slot.remaining}/${slot.maxPatients} tersisa',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: slot.status == 'Buka' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                slot.status,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: slot.status == 'Buka' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Paket Pemeriksaan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._packages.entries.map((entry) {
          final isSelected = _selectedPackage == entry.key;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPackage = entry.key;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? const Color(0xFF4A90E2).withValues(alpha: 0.05) : Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[400]!,
                        width: 2,
                      ),
                      color: isSelected ? const Color(0xFF4A90E2) : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? const Color(0xFF4A90E2) : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value.description,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(entry.value.price.toString()),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4A90E2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildComplaintField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Keluhan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _complaintController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Jelaskan keluhan Anda...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPrice() {
    final package = _packages[_selectedPackage]!;
    final consultationFee = double.tryParse(widget.doctor.consultationFee ?? '0') ?? 0;
    final total = package.price + consultationFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paket ${package.name}', style: GoogleFonts.poppins()),
              Text(_formatCurrency(package.price.toString()), style: GoogleFonts.poppins()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Biaya Konsultasi', style: GoogleFonts.poppins()),
              Text(_formatCurrency(widget.doctor.consultationFee ?? '0'), style: GoogleFonts.poppins()),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text(_formatCurrency(total.toString()),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4A90E2))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    final isAvailable = _selectedTime != null;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (_isSubmitting || !isAvailable) ? null : _bookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? const LoadingWidget()
            : Text(
          isAvailable ? 'Booking Janji' : 'Pilih Jadwal Terlebih Dahulu',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _formatCurrency(String amount) {
    try {
      final number = double.parse(amount);
      return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(number);
    } catch (e) {
      return 'Rp $amount';
    }
  }
}

class PackageInfo {
  final String name;
  final int price;
  final String description;

  PackageInfo({required this.name, required this.price, required this.description});
}