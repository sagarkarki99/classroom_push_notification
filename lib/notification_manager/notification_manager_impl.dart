import 'dart:developer';
import 'dart:io';

import 'package:classroom_push_notification/others/notification_navigation.dart';
import 'package:classroom_push_notification/others/notification_payload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_manager.dart';

Map<String, dynamic> _foregroundMessage = {};
late Function(String) _onNotificationClick;

class NotificationManagerImpl implements NotificationManager {
  final FlutterLocalNotificationsPlugin notificationClient;
  final NotificationNavigation notificationNavigation;
  VoidCallback? notificationRead;
  NotificationPayload Function(Map<String, dynamic>) getNotificationPayload;
  final String appIcon;

  NotificationManagerImpl({
    required this.notificationClient,
    required this.notificationNavigation,
    required this.getNotificationPayload,
    required this.appIcon,
  }) {
    _init();
  }

  @override
  Future<void> displayPopup(
      String title,
      String body,
      Map<String, dynamic> message,
      Function(String payload) onReadNotification) async {
    _onNotificationClick = onReadNotification;
    _foregroundMessage = message;
    await _displayNotification(title, body, message);
  }

  @override
  void navigate(Map<String, dynamic> message) {
    _handleNotificationNavigation(message);
  }

  Future<void> _init() async {
    if (Platform.isIOS) {
      _requestIosPermission();
    }

    final initializationSettings = InitializationSettings(
      android: _getAndroidSettings(),
      iOS: _getIosSettings(),
    );

    await notificationClient
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await notificationClient.initialize(
      initializationSettings,
      onSelectNotification: (payload) async => _openNotification(payload ?? ''),
    );
  }

  AndroidInitializationSettings _getAndroidSettings() =>
      AndroidInitializationSettings(appIcon);

  IOSInitializationSettings _getIosSettings() =>
      const IOSInitializationSettings();

  void _requestIosPermission() {
    if (notificationClient.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>() !=
        null) {
      notificationClient
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(
            alert: true,
            badge: true,
          );
    }
  }

  void _openNotification(String id) {
    _onNotificationClick(id);
    _handleNotificationNavigation(_foregroundMessage);
  }

  Future<void> _displayNotification(
      String title, String body, Map<String, dynamic> message) async {
    final androidDetails = _getAndroidNotificationDetail();
    final iosDetails = _getIosNotificationDetails();

    final notificationDetail = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationClient.show(
      0,
      title,
      body,
      notificationDetail,
      payload: message['messageId'] as String,
    );
  }

  void _handleNotificationNavigation(Map<String, dynamic> message) {
    notificationRead?.call();
    final payload = _getNotificationPayload(message);
    notificationNavigation.navigateTo(payload);
  }

  AndroidNotificationDetails _getAndroidNotificationDetail() =>
      const AndroidNotificationDetails(
        'fuse_notification_channel',
        'classroom',
        'Fuse Classroom',
        importance: Importance.high,
        priority: Priority.high,
      );

  AndroidNotificationChannel get _androidChannel =>
      const AndroidNotificationChannel(
        'fuse_notification_channel',
        'classroom',
        'Fuse Classroom',
        importance: Importance.high,
      );

  IOSNotificationDetails _getIosNotificationDetails() =>
      const IOSNotificationDetails();

  NotificationPayload _getNotificationPayload(Map<String, dynamic> message) {
    log(message.toString());
    return getNotificationPayload(message);
  }

  @override
  void onNotificationRead(VoidCallback onNotificationRead) {
    notificationRead = onNotificationRead;
  }
}

class NoDataPayload extends NotificationPayload {
  @override
  void trigger(BuildContext router) {}
}
