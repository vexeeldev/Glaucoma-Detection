import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/doctor_model.dart';
import '../../providers/doctor_provider.dart';
import 'doctor_detail_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialization = 'Semua';
  bool _isLoading = true;
  Map<int, bool> _availabilityStatus = {};
  Set<int> _loadingDoctors = {}; // Untuk tracking loading per dokter

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _searchController.addListener(_filterDoctors);
  }

  Future<void> _loadDoctors() async {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    await doctorProvider.loadDoctors();

    // Cek availability untuk setiap dokter
    await _checkAllDoctorsAvailability(doctorProvider);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAllDoctorsAvailability(DoctorProvider provider) async {
    final Map<int, bool> status = {};

    for (var doctor in provider.doctors) {
      // Tandai loading untuk dokter ini
      setState(() {
        _loadingDoctors.add(doctor.id);
      });

      final isAvailable = await provider.isDoctorAvailableToday(doctor.id);
      status[doctor.id] = isAvailable;

      // Hapus loading untuk dokter ini
      setState(() {
        _loadingDoctors.remove(doctor.id);
      });
    }

    setState(() {
      _availabilityStatus = status;
    });
  }

  void _filterDoctors() {
    setState(() {});
  }

  List<String> get specializations {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    return ['Semua', ...doctorProvider.specializations];
  }

  List<DoctorModel> get filteredDoctors {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    String query = _searchController.text.toLowerCase();

    return doctorProvider.doctors.where((doctor) {
      bool matchesSearch = doctor.name.toLowerCase().contains(query) ||
          doctor.specialization.toLowerCase().contains(query);
      bool matchesSpecialization = _selectedSpecialization == 'Semua' ||
          doctor.specialization == _selectedSpecialization;
      return matchesSearch && matchesSpecialization;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cari Dokter',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari dokter atau spesialis...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),

                // Specialization Filter
                Consumer<DoctorProvider>(
                  builder: (context, provider, child) {
                    if (provider.specializations.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: specializations.map((spec) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(spec),
                              selected: _selectedSpecialization == spec,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSpecialization = spec;
                                });
                              },
                              backgroundColor: Colors.grey[100],
                              selectedColor: const Color(0xFF4A90E2).withValues(alpha: 0.2),
                              checkmarkColor: const Color(0xFF4A90E2),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Doctors List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDoctors.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dokter tidak ditemukan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = filteredDoctors[index];
                final isAvailableToday = _availabilityStatus[doctor.id] ?? false;
                final isLoading = _loadingDoctors.contains(doctor.id);
                return _buildDoctorCard(doctor, isAvailableToday, isLoading);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor, bool isAvailableToday, bool isLoading) {
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            // Navigasi ke detail dokter
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorDetailScreen(doctorId: doctor.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Doctor Photo
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: doctor.profilePhoto != null && doctor.profilePhoto!.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          doctor.profilePhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF4A90E2),
                            );
                          },
                        ),
                      )
                          : const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Doctor Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor.specialization,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF4A90E2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (doctor.experience != null)
                            Text(
                              'Pengalaman: ${doctor.experience}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (doctor.consultationFee != null)
                            Text(
                              'Fee: Rp ${_formatCurrency(doctor.consultationFee!)}',
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
                const SizedBox(height: 12),

                // Status - Tersedia Hari Ini atau Tidak
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isLoading)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailableToday
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isAvailableToday ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAvailableToday ? 'Tersedia Hari Ini' : 'Tidak Tersedia Hari Ini',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isAvailableToday ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Tombol Lihat Detail
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailScreen(doctorId: doctor.id),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                      ),
                      child: const Text(
                        'Lihat Detail',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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