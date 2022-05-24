import 'dart:io';

import 'package:classroom_push_notification/notification_manager/notification_manager.dart';
import 'package:classroom_push_notification/push_notification/push_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationServiceImpl implements PushNotificationService {
  final NotificationManager notificationManager;
  final String? previousToken;

  late Function(String) _onReadNotification;
  final List<Function(Map<String, dynamic>)> _listeners = [];

  PushNotificationServiceImpl(
    this.notificationManager,
    this.previousToken,
  );
  @override
  Future<void> activate({
    required void Function(String) onRead,
    required void Function(String?) onActivated,
  }) async {
    _onReadNotification = onRead;
    if (Platform.isIOS) await FirebaseMessaging.instance.requestPermission();

    if (previousToken == null) {
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      onActivated(fcmToken);
      // await _registerToBackend(fcmToken ?? '');
      // await localSource.setValue(_fcmTokenKey, fcmToken ?? '');
    }
    //when app is started from terminated state
    final RemoteMessage? notificationStackMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (notificationStackMessage != null) {
      Future.delayed(const Duration(seconds: 1), () {
        _navigateToLocalNavigation(notificationStackMessage.data);
      });
    }

    //while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _notifyListeners(message.data);
      notificationManager.displayPopup(
        message.notification?.title ?? '',
        message.notification?.body ?? '',
        message.data,
        (String id) => markNotificationAsRead(id),
      );
    });

    //while app is in background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateToLocalNavigation(message.data);
    });
  }

  @override
  Future<void> deactivate({required Function(String) onDeactivated}) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.deleteToken();
    onDeactivated(fcmToken ?? '');
  }

  @override
  void listen(Function(Map<String, dynamic>) callback) {
    _listeners.add(callback);
  }

  void _navigateToLocalNavigation(Map<String, dynamic> data) {
    markNotificationAsRead(data['messageId'] as String);
    notificationManager.navigate(data);
  }

  void markNotificationAsRead(String messageId) {
    _onReadNotification(messageId);
  }

  void _notifyListeners(Map<String, dynamic> data) {
    for (var listener in _listeners) {
      listener(data);
    }
  }
}
