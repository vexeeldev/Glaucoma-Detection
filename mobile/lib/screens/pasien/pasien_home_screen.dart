import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/examination_card.dart';
import 'doctors_list_screen.dart';
import 'appointment_history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'examination_detail_screen.dart';

class PasienHomeScreen extends StatefulWidget {
  const PasienHomeScreen({super.key});

  @override
  State<PasienHomeScreen> createState() => _PasienHomeScreenState();
}

class _PasienHomeScreenState extends State<PasienHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _HomeScreen(),
      const DoctorsListScreen(),
      const AppointmentHistoryScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToTab(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final unreadCount = notifProvider.unreadCount;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Dokter',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifikasi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      await Future.wait([
        appointmentProvider.loadAppointments(user.id, user.role),
        appointmentProvider.loadExaminations(user.id, user.role),
      ]);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToTab(int index) {
    final pasienHomeState = context.findAncestorStateOfType<_PasienHomeScreenState>();
    if (pasienHomeState != null) {
      pasienHomeState._navigateToTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(
        child: Text('User tidak ditemukan'),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final upcomingAppointments = appointmentProvider.appointments
        .where((apt) =>
    apt.status == 'confirmed' &&
        apt.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    final recentExaminations = appointmentProvider.examinations
        .where((exam) => exam.status == 'completed')
        .take(3)
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user.name),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildUpcomingAppointments(upcomingAppointments),
            const SizedBox(height: 24),
            _buildRecentExaminations(recentExaminations),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo,',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            Text(
              userName,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF4A90E2).withValues(alpha: 0.1),
          child: const Icon(
            Icons.person,
            color: Color(0xFF4A90E2),
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAction(
            icon: Icons.calendar_month,
            label: 'Buat Janji',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorsListScreen()),
              );
            },
          ),
          _buildQuickAction(
            icon: Icons.history,
            label: 'Riwayat',
            onTap: () => _navigateToTab(2),
          ),
          _buildQuickAction(
            icon: Icons.notifications,
            label: 'Notifikasi',
            onTap: () => _navigateToTab(3),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(List appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Janji Temu Mendatang',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToTab(1),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        appointments.isEmpty
            ? _buildEmptyState(
          icon: Icons.calendar_today,
          message: 'Tidak ada janji temu',
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return AppointmentCard(
              appointment: appointments[index],
              onTap: () {
                // TODO: Navigate to appointment detail
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentExaminations(List examinations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pemeriksaan Terakhir',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToTab(2),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        examinations.isEmpty
            ? _buildEmptyState(
          icon: Icons.health_and_safety,
          message: 'Belum ada pemeriksaan',
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: examinations.length,
          itemBuilder: (context, index) {
            return ExaminationCard(
              examination: examinations[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExaminationDetailScreen(
                      examination: examinations[index],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}