import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiService.patientNotifications);

      if (response['success'] == true) {
        final List data = response['data'];
        _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.put(
        '${ApiService.patientNotifications}/$notificationId/read',
        {},
      );

      if (response['success'] == true) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index].isRead = true;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final response = await _apiService.put(
        '${ApiService.patientNotifications}/mark-all-read',
        {},
      );

      if (response['success'] == true) {
        for (var notification in _notifications) {
          notification.isRead = true;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete('${ApiService.patientNotifications}/$notificationId');

      if (response['success'] == true) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final response = await _apiService.delete('${ApiService.patientNotifications}/clear');

      if (response['success'] == true) {
        _notifications.clear();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    try {
      final response = await _apiService.post(
        '/api/mobile/notifications',
        notification.toJson(),
      );

      if (response['success'] == true) {
        _notifications.insert(0, notification);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }
}