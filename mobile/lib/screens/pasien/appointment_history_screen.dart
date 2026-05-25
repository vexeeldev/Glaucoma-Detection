import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
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
  bool _isLoadingDetail = false;
  final Map<int, dynamic> _bookingDetails = {};
  bool _isLoading = true;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    // Get providers before async operation
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await appointmentProvider.loadAppointments(
          authProvider.currentUser!.id,
          authProvider.currentUser!.role
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> get filterOptions => ['Semua', 'Aktif', 'Selesai'];

  Future<void> _fetchBookingDetail(int bookingId) async {
    if (_bookingDetails.containsKey(bookingId)) return;

    if (!mounted) return;

    setState(() {
      _isLoadingDetail = true;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.get('${ApiService.patientBooking}/$bookingId');
      debugPrint('Booking detail response for $bookingId: $response');

      if (response['status'] == 'success' && response['data'] != null && mounted) {
        setState(() {
          _bookingDetails[bookingId] = response['data'];
        });
        debugPrint('Payment details saved: ${response['data']['payment_details']}');
      }
    } catch (e) {
      debugPrint('Error fetching booking detail: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
        });
      }
    }
  }

  // Fix 1: _processPayment method - use mounted check properly
  Future<void> _processPayment(int appointmentId) async {
    if (!mounted) return;

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final success = await appointmentProvider.confirmPayment(
        appointmentId: appointmentId,
        paymentMethod: 'transfer',
      );

      if (mounted && success) {
        await _loadData();
        if (mounted) {
          // Use context directly with mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran berhasil!'), backgroundColor: Colors.green),
          );
          await _fetchBookingDetail(appointmentId);
        }
      } else if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses pembayaran'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  String _getAppointmentStatusDisplay(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Menunggu Pembayaran';
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

  Color _getAppointmentStatusColor(String status) {
    switch (status) {
      case 'pending_payment':
        return Colors.orange;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsTab(),
          _buildExaminationsTab(),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return Column(
      children: [
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

        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                var appointments = provider.appointments;

                if (_selectedFilter == 'Aktif') {
                  appointments = appointments.where((apt) =>
                  apt.status == 'pending_payment' ||
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

                appointments.sort((a, b) => b.date.compareTo(a.date));

                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada riwayat janji',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                          ),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(appointments[index]);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final statusColor = _getAppointmentStatusColor(appointment.status);
    final statusDisplay = _getAppointmentStatusDisplay(appointment.status);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showAppointmentDetail(appointment),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.calendar_month, color: statusColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(appointment.date),
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                appointment.time,
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
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusDisplay,
                        style: GoogleFonts.poppins(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                if (appointment.status == 'pending_payment' ||
                    appointment.status == 'pending' ||
                    appointment.status == 'paid' ||
                    appointment.status == 'confirmed')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _showCancelDialog(appointment.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Batalkan'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExaminationsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          final examinations = provider.examinations;

          if (examinations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.health_and_safety, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Belum ada pemeriksaan', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2)),
                    child: const Text('Refresh'),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      color: examination.prediction == 'Glaukoma' ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(examination.doctorName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                            color: examination.prediction == 'Glaukoma' ? Colors.red : Colors.green,
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
                        builder: (_) => ExaminationDetailScreen(examination: examination),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Fix 2: _showAppointmentDetail method - restructure to avoid async gaps
  void _showAppointmentDetail(AppointmentModel appointment) async {
    final bookingId = int.parse(appointment.id);

    // Load detail first
    if (!_bookingDetails.containsKey(bookingId)) {
      await _fetchBookingDetail(bookingId);
    }

    // Check mounted before showing dialog
    if (!mounted) return;

    final detail = _bookingDetails[bookingId];
    final paymentDetails = detail?['payment_details'];
    final appointmentDetails = detail?['appointment_details'];
    final isPending = appointment.status == 'pending_payment';

    // Show dialog after all async operations are complete
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Detail Janji'),
          content: _isLoadingDetail || _isProcessingPayment
              ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Dokter', appointmentDetails?['doctor_name'] ?? appointment.doctorName),
                const SizedBox(height: 8),
                _buildDetailRow('Spesialis', appointmentDetails?['specialization'] ?? '-'),
                const SizedBox(height: 8),
                _buildDetailRow('Tanggal', DateFormat('dd MMMM yyyy').format(appointment.date)),
                const SizedBox(height: 8),
                _buildDetailRow('Jam', appointment.time),
                const SizedBox(height: 8),
                _buildDetailRow('Keluhan', appointment.complaint),
                const SizedBox(height: 8),
                _buildDetailRow('Status', _getAppointmentStatusDisplay(appointment.status)),
                if (appointment.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Alasan Penolakan', appointment.rejectionReason!),
                ],
                if (paymentDetails != null) ...[
                  const Divider(height: 24),
                  Text('Informasi Pembayaran', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildDetailRow('Invoice', paymentDetails['invoice_number'] ?? '-'),
                  _buildDetailRow('Total', _formatCurrency(paymentDetails['amount'] ?? '0')),
                  _buildDetailRow('Status Bayar', paymentDetails['payment_status'] == 'unpaid' ? 'Belum Dibayar' : 'Sudah Dibayar'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
            if (isPending && !_isProcessingPayment)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _processPayment(bookingId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bayar Sekarang'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  // Fix 3: _showCancelDialog - move async operation inside the builder
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
                // Close dialog first
                Navigator.pop(dialogContext);

                // Then perform async operation
                final provider = Provider.of<AppointmentProvider>(context, listen: false);
                final success = await provider.cancelAppointment(appointmentId);

                if (mounted && success) {
                  await _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Janji berhasil dibatalkan'), backgroundColor: Colors.green),
                    );
                  }
                } else if (mounted && !success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal membatalkan janji'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
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