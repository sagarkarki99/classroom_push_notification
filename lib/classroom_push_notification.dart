library classroom_push_notification;

import 'package:classroom_push_notification/notification_manager_impl.dart';
import 'package:classroom_push_notification/notification_navigation.dart';
import 'package:classroom_push_notification/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ClassroomPushNotification {
  late PushNotificationService pushNotification;
  FirebaseApp firebaseApp;
  NotificationNavigation nav;

  ClassroomPushNotification({
    required this.firebaseApp,
    required this.nav,
  }) {
    pushNotification = PushNotificationServiceImpl(
      NotificationManagerImpl(
        notificationClient: FlutterLocalNotificationsPlugin(),
        notificationNavigation: nav,
      ),
      null,
    );
  }

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
