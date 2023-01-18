import 'dart:developer';
import 'package:alcancia/main.dart';
import 'package:alcancia/src/resources/colors/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  inspect(message);
}

void firebaseMessagingOpenAppHandler(RemoteMessage message) {
  print("Handling a opened message: ${message.messageId}");
  navigatorKey.currentContext!.go("/registration");
}

void handleInitialMessage(RemoteMessage message) {
  print("Handling initial message: ${message.messageId}");
  navigatorKey.currentContext!.go("/login");
}

class PushNotificationProvider {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    messaging.requestPermission();

    messaging.getToken().then((token) {
      // device token
      print('this is the token: ');
      print(token);
    });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleInitialMessage(initialMessage);
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(firebaseMessagingOpenAppHandler);


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message in the foreground!');
      print('Message data: ${message.data}');
      Fluttertoast.showToast(msg: message.notification!.body!, toastLength: Toast.LENGTH_LONG, backgroundColor: alcanciaLightBlue, timeInSecForIosWeb: 5);
      inspect(message);

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      // send to dashboard screen
      navigatorKey.currentContext!.go("/registration");
    });
  }
}

final pushNotificationProvider = Provider((ref) => PushNotificationProvider());