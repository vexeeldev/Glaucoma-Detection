import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/doctor_model.dart';
import '../../services/mock_data_service.dart';
import 'book_appointment_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final MockDataService _mockDataService = MockDataService();
  List<DoctorModel> _doctors = [];
  List<DoctorModel> _filteredDoctors = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialization = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _searchController.addListener(_filterDoctors);
  }

  void _loadDoctors() {
    setState(() {
      _doctors = _mockDataService.getDoctors();
      _filteredDoctors = _doctors;
    });
  }

  void _filterDoctors() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        bool matchesSearch = doctor.name.toLowerCase().contains(query) ||
            doctor.specialization.toLowerCase().contains(query);
        bool matchesSpecialization = _selectedSpecialization == 'Semua' ||
            doctor.specialization.contains(_selectedSpecialization);
        return matchesSearch && matchesSpecialization;
      }).toList();
    });
  }

  List<String> get specializations {
    Set<String> specs = {'Semua'};
    specs.addAll(_doctors.map((d) => d.specialization).toSet());
    return specs.toList();
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
                SingleChildScrollView(
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
                              _filterDoctors();
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
              ],
            ),
          ),

          // Doctors List
          Expanded(
            child: _filteredDoctors.isEmpty
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
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _filteredDoctors[index];
                return _buildDoctorCard(doctor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookAppointmentScreen(doctor: doctor),
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
                      child: doctor.photoUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          doctor.photoUrl,
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
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  doctor.schedule,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (doctor.experience > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${doctor.experience} tahun pengalaman',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quota and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: doctor.isAvailable
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
                              color: doctor.isAvailable ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor.isAvailable ? 'Tersedia' : 'Penuh',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: doctor.isAvailable ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Kuota: ${doctor.availableQuota} pasien',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
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
}