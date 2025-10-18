// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/native_controller/audio_native_controller.dart';
import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:whoxachat/src/screens/call/web_rtc/incoming_call_screen.dart';
import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:whoxachat/src/screens/chat/group_chat_temp.dart';
import 'package:whoxachat/src/screens/chat/single_chat.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OnesignalService {
  final RoomIdController roomIdController = Get.put(RoomIdController());

  initialize() {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize(
        languageController.appSettingsOneSignalData[0].oneSignalAppId!);
    // OneSignal.initialize("fa0d2111-1ab5-49d7-ad5d-976b8d9d66a4");
    OneSignal.User.pushSubscription.addObserver((state) {
      print(
          "pushSubscription optedIn ${OneSignal.User.pushSubscription.optedIn}");
      print("pushSubscription id ${OneSignal.User.pushSubscription.id}");
      print("pushSubscription token ${OneSignal.User.pushSubscription.token}");
      print(
          "pushSubscription current.jsonRepresentation ${state.current.jsonRepresentation()}");
    });

    OneSignal.Notifications.requestPermission(true);
  }

  onNotifiacation() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print("event body ${event.notification.additionalData}");
      if (event.notification.additionalData!['call_type'].toString() ==
          'video_call') {
        print("video call");
        if (event.notification.additionalData!['missed_call'].toString() ==
            'true') {
          OneSignal.Notifications.clearAll();
          stopRingtone();
          Get.offAll(
            TabbarScreen(
              currentTab: 0,
            ),
          );
          Get.put(ChatListController()).forChatList();
        } else {
          Get.to(IncomingCallScrenn(
            roomID: event.notification.additionalData!['room_id'].toString(),
            callerImage: event
                .notification.additionalData!['sender_profile_image']
                .toString(),
            senderName:
                event.notification.additionalData!['senderName'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            message_id:
                event.notification.additionalData!['message_id'].toString(),
            caller_id:
                event.notification.additionalData!['senderId'].toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
          FlutterRingtonePlayer().playRingtone();

          AudioManager.setEarpiece();
        }
      } else if (event.notification.additionalData!['call_type'].toString() ==
          'audio_call') {
        print("audio call");
        if (event.notification.additionalData!['missed_call'].toString() ==
            "true") {
          OneSignal.Notifications.clearAll();
          stopRingtone();
          Get.offAll(
            TabbarScreen(
              currentTab: 0,
            ),
          );
          Get.put(ChatListController()).forChatList();
        } else {
          Get.to(IncomingCallScrenn(
            roomID: event.notification.additionalData!['room_id'].toString(),
            callerImage: event
                .notification.additionalData!['sender_profile_image']
                .toString(),
            senderName:
                event.notification.additionalData!['senderName'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            message_id:
                event.notification.additionalData!['message_id'].toString(),
            caller_id:
                event.notification.additionalData!['senderId'].toString(),
            forVideoCall: false,
            receiverImage: event
                .notification.additionalData!['receiver_profile_image']
                .toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
          FlutterRingtonePlayer().playRingtone();
          AudioManager.setEarpiece();
        }
      }
    });
  }

  onNotificationClick() {
    OneSignal.Notifications.addClickListener((event) {
      if (event.result.actionId == "accept") {
        print("actionId accept");
        if (event.notification.additionalData!['call_type'].toString() ==
            'video_call') {
          print("video call");

          stopRingtone();
          Get.off(VideoCallScreen(
            roomID: event.notification.additionalData!['room_id'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
        } else if (event.notification.additionalData!['call_type'].toString() ==
            'audio_call') {
          print("audio call");

          stopRingtone();
          Get.off(AudioCallScreen(
            roomID: event.notification.additionalData!['room_id'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            receiverImage: event
                .notification.additionalData!["sender_profile_image"]
                .toString(),
            receiverUserName:
                event.notification.additionalData!["senderName"].toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
        }
      } else if (event.result.actionId == "decline") {
        print("actionId decline");
        if (event.notification.additionalData!['call_type'].toString() ==
            'video_call') {
          stopRingtone();
          if (event.notification.additionalData!['is_group'].toString() ==
              "true") {
            Get.offAll(
              TabbarScreen(
                currentTab: 0,
              ),
            );
          } else {
            roomIdController.callCutByReceiver(
              conversationID: event
                  .notification.additionalData!['conversation_id']
                  .toString(),
              message_id:
                  event.notification.additionalData!['message_id'].toString(),
              caller_id:
                  event.notification.additionalData!['senderId'].toString(),
            );
          }
        } else if (event.notification.additionalData!['call_type'].toString() ==
            'audio_call') {
          stopRingtone();
          if (event.notification.additionalData!['is_group'].toString() ==
              "true") {
            Get.offAll(
              TabbarScreen(
                currentTab: 0,
              ),
            );
          } else {
            roomIdController.callCutByReceiver(
              conversationID: event
                  .notification.additionalData!['conversation_id']
                  .toString(),
              message_id:
                  event.notification.additionalData!['message_id'].toString(),
              caller_id:
                  event.notification.additionalData!['senderId'].toString(),
            );
          }
        }
      } else {
        if (event.notification.additionalData!['call_type'].toString() ==
                'video_call' &&
            event.notification.additionalData!['missed_call'].toString() ==
                'false') {
          stopRingtone();
          Get.to(IncomingCallScrenn(
            roomID: event.notification.additionalData!['room_id'].toString(),
            callerImage: event
                .notification.additionalData!['sender_profile_image']
                .toString(),
            senderName:
                event.notification.additionalData!['senderName'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            message_id:
                event.notification.additionalData!['message_id'].toString(),
            caller_id:
                event.notification.additionalData!['senderId'].toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
        } else if (event.notification.additionalData!['call_type'].toString() ==
                'audio_call' &&
            event.notification.additionalData!['missed_call'].toString() ==
                'false') {
          stopRingtone();
          Get.to(IncomingCallScrenn(
            roomID: event.notification.additionalData!['room_id'].toString(),
            callerImage: event
                .notification.additionalData!['sender_profile_image']
                .toString(),
            senderName:
                event.notification.additionalData!['senderName'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            message_id:
                event.notification.additionalData!['message_id'].toString(),
            caller_id:
                event.notification.additionalData!['senderId'].toString(),
            forVideoCall: false,
            receiverImage: event
                .notification.additionalData!['receiver_profile_image']
                .toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
        } else if (event.notification.additionalData!['notification_type']
                    .toString() ==
                'message' &&
            event.notification.additionalData!['is_group'].toString() ==
                'false') {
          // Get.find<SingleChatContorller>().getdetailschat(
          //     event.notification.additionalData!['conversation_id'].toString());
          Get.to(SingleChatMsg(
            conversationID: event
                .notification.additionalData!['conversation_id']
                .toString(),
            username:
                event.notification.additionalData!['senderName'].toString(),
            userPic:
                event.notification.additionalData!['profile_image'].toString(),
            index: 0,
            isMsgHighLight: false,
            isBlock: bool.parse(event.notification.additionalData!['is_block']),
            userID: event.notification.additionalData!['senderId'].toString(),
          ));
        } else if (event.notification.additionalData!['notification_type']
                    .toString() ==
                'message' &&
            event.notification.additionalData!['is_group'].toString() ==
                'true') {
          Get.to(GroupChatMsg(
            conversationID: event
                .notification.additionalData!['conversation_id']
                .toString(),
            gPusername:
                event.notification.additionalData!['senderName'].toString(),
            gPPic:
                event.notification.additionalData!['profile_image'].toString(),
            index: 0,
            isMsgHighLight: false,
          ));
        }
      }
    });
  }
}

stopRingtone() {
  if (Platform.isAndroid) {
    FlutterRingtonePlayer().stop();
  } else {
    AudioManager.pauseAudio();
  }
}
