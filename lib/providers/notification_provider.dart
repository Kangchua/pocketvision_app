import 'package:flutter/material.dart';
import '../models/notification.dart' as app_notification;
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<app_notification.AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<app_notification.AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _apiService.getNotifications();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiService.markNotificationAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = app_notification.AppNotification(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          type: _notifications[index].type,
          message: _notifications[index].message,
          relatedId: _notifications[index].relatedId,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.markAllNotificationsAsRead();
      _notifications = _notifications.map((n) => app_notification.AppNotification(
        id: n.id,
        userId: n.userId,
        type: n.type,
        message: n.message,
        relatedId: n.relatedId,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _apiService.deleteNotification(id);
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      // Xóa từng thông báo một (vì backend chưa có endpoint xóa tất cả)
      final ids = _notifications.map((n) => n.id).toList();
      for (final id in ids) {
        try {
          await _apiService.deleteNotification(id);
        } catch (e) {
          // Continue deleting others even if one fails
        }
      }
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  app_notification.AppNotification? getNotificationById(int id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  List<app_notification.AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();

  List<app_notification.AppNotification> get readNotifications => 
      _notifications.where((n) => n.isRead).toList();

  int get unreadCount => unreadNotifications.length;
}