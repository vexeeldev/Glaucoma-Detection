import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when opening notifications screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // In a real app, you might want to mark only visible ones as read
        // final provider = Provider.of<NotificationProvider>(context, listen: false);
        // provider.markAllAsRead();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    // Uncomment this when markAllAsRead is implemented
    // final provider = Provider.of<NotificationProvider>(
    //   context,
    //   listen: false,
    // );
    // provider.markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah dibaca'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return GestureDetector(
      onTap: () {
        _handleNotificationTap(notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : const Color(0xFF4A90E2).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Colors.grey[200]!
                : const Color(0xFF4A90E2).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon based on type
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getIconColor(notification.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(notification.type),
                color: _getIconColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A90E2),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateFormat.format(notification.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[400],
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

  IconData _getIcon(String type) {
    switch (type) {
      case 'appointment_confirmed':
        return Icons.check_circle;
      case 'appointment_rejected':
        return Icons.cancel;
      case 'payment_success':
        return Icons.payment;
      case 'examination_ready':
        return Icons.health_and_safety;
      case 'new_appointment':
        return Icons.calendar_month;
      case 'ml_processed':
        return Icons.analytics;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'appointment_confirmed':
        return Colors.green;
      case 'appointment_rejected':
        return Colors.red;
      case 'payment_success':
        return Colors.blue;
      case 'examination_ready':
        return Colors.purple;
      case 'new_appointment':
        return Colors.orange;
      case 'ml_processed':
        return Colors.teal;
      default:
        return const Color(0xFF4A90E2);
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      provider.markAsRead(notification.id);
    }

    // Navigate based on notification type and data
    switch (notification.type) {
      case 'appointment_confirmed':
      case 'appointment_rejected':
      // Navigate to appointment detail
        if (notification.data != null && notification.data!.containsKey('appointmentId')) {
          // TODO: Navigate to appointment detail screen
          _showComingSoonSnackBar();
        }
        break;
      case 'examination_ready':
      // Navigate to examination result
        if (notification.data != null && notification.data!.containsKey('examinationId')) {
          // TODO: Navigate to examination detail screen
          _showComingSoonSnackBar();
        }
        break;
      default:
        _showComingSoonSnackBar();
        break;
    }
  }

  void _showComingSoonSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur navigasi akan segera tersedia',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}