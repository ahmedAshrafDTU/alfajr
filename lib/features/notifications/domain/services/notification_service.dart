import 'dart:async';

/// Local notification message model.
class AppNotification {
  final String title;
  final String body;
  final DateTime timestamp;

  const AppNotification({
    required this.title,
    required this.body,
    required this.timestamp,
  });
}

/// Notification service abstraction for local alerts and status broadcast.
class NotificationService {
  final List<AppNotification> _notifications = [];
  final _controller = StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get onNotification => _controller.stream;
  List<AppNotification> get notificationHistory => List.unmodifiable(_notifications);

  /// Shows or schedules an in-app / local push notification.
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    final notif = AppNotification(
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, notif);
    _controller.add(notif);
  }

  /// Dispatches session status update notification.
  Future<void> notifySessionProgress({
    required int totalUsers,
    required int awakeCount,
    required int prayedCount,
  }) async {
    await showNotification(
      title: 'متابعة جلسة الفجر الحالية',
      body: '$awakeCount من $totalUsers استيقظوا | $prayedCount أكدوا أداء الصلاة',
    );
  }

  void dispose() {
    _controller.close();
  }
}
