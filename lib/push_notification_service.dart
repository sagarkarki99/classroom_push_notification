import 'dart:io';

import 'package:classroom_push_notification/notification_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

abstract class PushNotificationService {
  ///activate remote push notification service when user is authenticated
  Future<void> activate({
    required void Function(String) onRead,
    required void Function(String?) onActivated,
  });

  ///deactivate remote push notification service when user is unauthenticated
  Future<void> deactivate();

  /// a listener which listens to changes when a push notification arrives when app is active state.
  void onNotificationReceived(VoidCallback onNotificationCountIncreased);
}

class PushNotificationServiceImpl implements PushNotificationService {
  final NotificationManager notificationManager;
  final String? previousToken;

  late Function(String) _onReadNotification;

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
  Future<void> deactivate() {
    // TODO: implement deactivate
    throw UnimplementedError();
  }

  @override
  void onNotificationReceived(VoidCallback onNotificationCountIncreased) {
    // TODO: implement onNotificationReceived
  }

  void _navigateToLocalNavigation(Map<String, dynamic> data) {
    markNotificationAsRead(data['messageId'] as String);
    notificationManager.navigate(data);
  }

  void markNotificationAsRead(String messageId) {
    _onReadNotification(messageId);
  }
}
