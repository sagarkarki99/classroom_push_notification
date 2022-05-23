library classroom_push_notification;

import 'package:classroom_push_notification/notification_manager.dart';
import 'package:classroom_push_notification/notification_manager_impl.dart';
import 'package:classroom_push_notification/notification_navigation.dart';
import 'package:classroom_push_notification/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ClassroomPushNotification {
  late PushNotificationService pushNotification;
  late FirebaseApp firebaseApp;
  late NotificationNavigation nav;
  late NotificationManager _manager;
  static late ClassroomPushNotification _instance;

  ClassroomPushNotification._internal({
    required this.firebaseApp,
    required this.nav,
  }) {
    _manager = NotificationManagerImpl(
      notificationClient: FlutterLocalNotificationsPlugin(),
      notificationNavigation: nav,
    );
    pushNotification = PushNotificationServiceImpl(
      _manager,
      null,
    );
  }

  static ClassroomPushNotification initialize(
      FirebaseApp firebaseApp, NotificationNavigation nav) {
    _instance =
        ClassroomPushNotification._internal(firebaseApp: firebaseApp, nav: nav);
    return _instance;
  }

  static ClassroomPushNotification get instance => _instance;
  NotificationManager get notificationManager => _manager;

  Future<void> activate({
    required void Function(String) onRead,
    required void Function(String?) onActivated,
  }) async {
    await pushNotification.activate(
      onRead: onRead,
      onActivated: onActivated,
    );
  }

  Future<void> deactivate() async {
    await pushNotification.deactivate();
  }
}
