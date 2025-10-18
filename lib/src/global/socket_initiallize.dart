// ignore_for_file: file_names, library_prefixes

import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/controller/online_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIntilized {
  OnlineOfflineController controller = Get.put(OnlineOfflineController());
  IO.Socket? socket;
  initlizedsocket() async {
    socket = IO.io(
        '${socketBaseUrl()}/?token=${Hive.box(userdata).get(authToken).toString()}',
        <String, dynamic>{
          'transports': ['websocket'],
          'path': '/socket'
        });
    log('${socketBaseUrl()}/?user_id=${Hive.box(userdata).get(authToken).toString()} USER ID ');
    if (kDebugMode) {
      print("Socket Activated");
    }
    controller.forData();
    controller.offlineUser();
    controller.isTyping();
  } 
} 
 