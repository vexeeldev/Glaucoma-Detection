import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/mock_data_service.dart';

class NotificationProvider extends ChangeNotifier {
  final MockDataService _mockDataService = MockDataService();
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    _notifications = _mockDataService.getNotificationsByUser(userId);
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    _mockDataService.markNotificationAsRead(notificationId);
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        isRead: true,
        createdAt: _notifications[index].createdAt,
        data: _notifications[index].data,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    for (var notification in _notifications) {
      if (!notification.isRead) {
        await markAsRead(notification.id);
      }
    }
  }

  void addNotification(NotificationModel notification) {
    _mockDataService.addNotification(notification);
    _notifications.insert(0, notification);
    notifyListeners();
  }
}