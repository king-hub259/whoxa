// ignore_for_file: avoid_print, empty_catches, unused_local_variable, use_build_context_synchronously, depend_on_referenced_packages, unused_import, unused_field

import 'dart:developer';
import 'dart:io';

// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';

import 'package:whoxachat/controller/get_delete_story.dart';
import 'package:whoxachat/controller/launguage_controller.dart';
import 'package:whoxachat/main.dart';
import 'package:whoxachat/src/Notification/notifiactions_handler.dart';
import 'package:whoxachat/src/Notification/notification_service.dart';
import 'package:whoxachat/src/Notification/one_signal_service.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:whoxachat/src/screens/call/web_rtc/incoming_call_screen.dart';
import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:whoxachat/src/screens/user/create_profile.dart';
import 'package:whoxachat/src/screens/user/profile.dart';
import 'package:whoxachat/welcome.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'src/screens/layout/bottombar.dart';

LanguageController languageController = Get.find();

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with WidgetsBindingObserver {
  GetDeleteStroy deleteStroy = Get.put(GetDeleteStroy());
  String? _currentUuid;
  late final Uuid _uuid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // requestPermissions(); due to multiple request of permission this code is not work
    requestAndCheckPermissions();
    print(
        "OneSignal pushSubscription optedIn ${OneSignal.User.pushSubscription.optedIn}");
    print(
        "OneSignal pushSubscription id ${OneSignal.User.pushSubscription.id}");
    print(
        "OneSignal pushSubscription token ${OneSignal.User.pushSubscription.token}");

    OnesignalService().onNotifiacation();
    OnesignalService().onNotificationClick();

    // _checkPermissions(); due to multiple request of permission this code is not work
    // FirebaseMessagingService().setUpFirebase();

    deleteStroy.getDelete();
    log("AuthToken: ${Hive.box(userdata).get(authToken)}");
  }

  // ignore: unused_element
  Future<void> _checkPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      addContactController.getContactsFromGloble();
    } else {
      if (Platform.isAndroid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Contacts permission is required to use this feature')),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _handleCurrentScreen();
  }

  Widget _handleCurrentScreen() {
    var box = Hive.box(userdata);

    if (box.get(authToken) != null &&
        box.get(lastName) != null &&
        box.get(lastName)!.isNotEmpty &&
        box.get(firstName) != null &&
        box.get(firstName)!.isNotEmpty) {
      print("☺☺☺☺GO TO HOME PAGE☺☺☺☺");
      return TabbarScreen();
    } else if (box.get(authToken) == null &&
        box.get(lastName) == null &&
        box.get(firstName) == null) {
      print("☺☺☺☺GO TO WELCOME SCREEN☺☺☺☺");
      return const Welcome();
    } else {
      print("☺☺☺☺GO TO CREATE PROFILE☺☺☺☺");
      return AddPersonaDetails(isRought: false, isback: false);
    }
  }

  // Future<void> requestPermissions() async {
  //   await Permission.notification.request();

  //   await Permission.camera.request();

  //   await Permission.microphone.request();

  //   await Permission.storage.request();

  //   await Permission.photos.request();
  // }

  Future<void> requestAndCheckPermissions() async {
    try {
      // Request all permissions together
      Map<Permission, PermissionStatus> statuses = await [
        Permission.notification,
        Permission.camera,
        Permission.microphone,
        Permission.storage,
        Permission.photos,
        Permission.contacts,
      ].request();

      // Check if contacts permission was granted and perform contact-related actions
      if (statuses[Permission.contacts]?.isGranted ?? false) {
        addContactController.getContactsFromGloble();
      } else if (Platform.isAndroid) {
        // Only show this message if we're on Android
        if (mounted) {
          // Check if widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Contacts permission is required to use this feature')),
          );
        }
      }
    } catch (e) {
      // Handle any errors that might occur during permission requests
      print("Error requesting permissions: $e");
    }
  }
}
