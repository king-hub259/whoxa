// ignore_for_file: must_be_immutable, depend_on_referenced_packages, constant_identifier_names, avoid_print, non_constant_identifier_names, unused_field, deprecated_member_use

//
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:hive/hive.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/main.dart';
import 'package:whoxachat/native_controller/audio_native_controller.dart';
import 'package:whoxachat/src/Notification/one_signal_service.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/call/web_rtc/joiend_users.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:peerdart/peerdart.dart';
import 'package:uuid/uuid.dart';

class VideoCallScreen extends StatefulWidget {
  String? roomID;
  String? isGroupCall;
  String conversation_id;
  bool isCaller = false;
  VideoCallScreen(
      {super.key,
      this.roomID,
      this.isGroupCall,
      required this.conversation_id,
      this.isCaller = false});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Peer? myPeer;
  Map<String, MediaConnection> peers = {};

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> remoteRenderers = {};

  final RoomIdController roomIdController = getx.Get.put(RoomIdController());

  String? peerid;
  bool inCall = false;
  bool isScreenBig = true;
  bool isReciverConnect = false;
  bool isCallCutByMe = false;
  bool isCallCutCall = false;

  @override
  void initState() {
    super.initState();
    callingRingtone();
    _initializeRenderers();
    checkIsRemoteUsersJoined();
    roomIdController.joinUsers(
      isCaller: widget.isCaller,
      isGroupCall: bool.parse(widget.isGroupCall!),
      callback: () {
        log("callback call");
        if (roomIdController.connnectdUsersData.length == 1) {
          log("remoteRenderers length first ${remoteRenderers.length}");

          Future.delayed(
            const Duration(seconds: 2),
            () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  endedCall(context);
                }
              });
              disposeLocalRender();
              disposeRemoteRender();
              getx.Get.find<ChatListController>().forChatList();
            },
          );
        }
      },
    );
  }

  late Future _delayedCheckFuture;

  checkIsRemoteUsersJoined() async {
    _delayedCheckFuture = Future.delayed(
      const Duration(seconds: 45),
      () {
        if (remoteRenderers.isEmpty) {
          if (widget.isCaller == true) {
            stopRingtone();
          }
          if (isReciverConnect == false &&
              widget.isCaller == true &&
              isCallCutCall == false) {
            print("callCutByMe calling...");
            roomIdController.callCutByMe(
                conversationID: widget.conversation_id, callType: "video_call");
          }

          setState(() {
            inCall = false;
          });
          disposeLocalRender();
          disposeRemoteRender();
          getx.Get.find<ChatListController>().forChatList();
          getx.Get.offAll(
            TabbarScreen(
              currentTab: 0,
            ),
          );
        }
      },
    );
  }

  callingRingtone() {
    if (widget.isCaller == true && remoteRenderers.isEmpty) {
      AudioManager.setEarpiece();
      if (Platform.isAndroid) {
        FlutterRingtonePlayer().play(
          fromAsset: 'assets/audio/calling.mp3',
          looping: true,
        );
      } else {
        AudioManager.playAudio(
          audioFile: 'calling.mp3',
        );
      }
    }
  }

  Future<void> _initializeRenderers() async {
    await localRenderer.initialize();
    print("ROOMID ${widget.roomID}");
    await _initPeer();
  }

  static const CLOUD_HOST = ApiHelper.baseUrlIp;

  static const CLOUD_PORT = 4001;

  Future<void> _initPeer() async {
    try {
      myPeer = Peer(
        id: "${const Uuid().v4()}/${Hive.box(userdata).get(userId).toString()}",
        options: PeerOptions(
          port: CLOUD_PORT,
          host: CLOUD_HOST,
          secure: false,
          path: '/',
        ),
      );
    } catch (e) {
      print('Unhandled exception in _initPeer: $e');
    }

    myPeer!.on("open").listen((event) {
      setState(() {
        peerid = event.toString();
      });
      print("PEERID☺☺☺☺☺☺☺:$event");
      socketIntilized.socket!
          .emit("join-call", {"room_id": widget.roomID, "user_id": event});
    });

    connectNewUser(userId, MediaStream mediaStream) async {
      print('new connected userid $userId');
      print('new connected stream $mediaStream');

      final call = myPeer!.call(userId, mediaStream);
      print('new connected user... ${call.connectionId}');

      call.on<MediaStream>("stream").listen((stream) async {
        print("call.peer ${call.peer}");
        if (!remoteRenderers.containsKey(call.peer)) {
          RTCVideoRenderer renderer = RTCVideoRenderer();
          await renderer.initialize();
          if (mounted) {
            setState(() {
              remoteRenderers[call.peer] = renderer;
            });
          }
        }
        remoteRenderers[userId]!.srcObject = stream;
        print("remoteStream $stream");
        print("remoteRenderers length third ${remoteRenderers.length}");
      });

      call.on("close").listen((onData) {
        print("call closed");
        if (remoteRenderers[userId] != null) {
          remoteRenderers[userId]!.dispose();
          remoteRenderers.remove(userId);
          print("remoteRenderers length fourth ${remoteRenderers.length}");
        }
      });

      peers[userId] = call;
      print("peers $peers");
    }

    navigator.mediaDevices.getUserMedia({
      'video': Platform.isAndroid
          ? true
          : {
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
              },
              'facingMode': 'user',
            },
      "audio": true
    }).then((mediaStream) async {
      localRenderer.srcObject = mediaStream;
      print('my stream $mediaStream');
      await Helper.setSpeakerphoneOn(false);

      myPeer!.on<MediaConnection>("call").listen((call) {
        print("call from ${call.peer} to $peerid");
        print('my stream $mediaStream');
        call.answer(mediaStream);

        call.on<MediaStream>("stream").listen((remoteStream) async {
          if (!remoteRenderers.containsKey(call.peer)) {
            RTCVideoRenderer renderer = RTCVideoRenderer();

            await renderer.initialize();

            remoteRenderers[call.peer] = renderer;
            remoteRenderers[call.peer]!.srcObject = remoteStream;
          }
          setState(() {});
          print("remoteRenderers length fifth ${remoteRenderers.length}");
          print("remoteStream $remoteStream");
        });
        print("call peer ${call.peer}");
        peers[call.peer] = call;
      });
      socketIntilized.socket!.on(
        "user-connected-to-call",
        (userId) async {
          if (widget.isCaller == true) {
            stopRingtone();
          }
          print("PEERID☺☺☺☺☺☺☺ remote: $userId");
          connectNewUser(userId, mediaStream);
          isReciverConnect = true;
        },
      );
    });

    socketIntilized.socket!.on(
        "user-disconnected-from-call",
        (userId) => {
              print("disconnected  $userId"),
              print("peers $peers"),
              print("TESTING 1"),
              print("remoteRenderers $remoteRenderers"),
              print("remoteRenderers length sixth ${remoteRenderers.length}"),
              if (peers[userId] != null)
                {
                  print("TESTING 2"),
                  print("disconnected userid $userId"),
                  peers[userId]!.close(),
                  if (remoteRenderers[userId] != null)
                    {
                      print("TESTING 3"),
                      remoteRenderers[userId]!.dispose(),
                      remoteRenderers.remove(userId),
                      print("TESTING 4"),
                      if (remoteRenderers.isEmpty)
                        {
                          print("TESTING 5"),
                          socketIntilized.socket!.emit("leave-call", {
                            "room_id": widget.roomID,
                            "user_id": myPeer!.id
                          }),
                          disposeLocalRender(),
                          disposeRemoteRender(),
                          getx.Get.find<ChatListController>().forChatList(),
                          getx.Get.offAll(
                            TabbarScreen(
                              currentTab: 0,
                            ),
                          ),
                          print("TESTING 6"),
                          print("TESTING 7"),
                        }
                    },
                  setState(() {}),
                  print("disconnected peers[userId] ${peers[userId]}"),
                  print(
                      "remoteRenderers length second ${remoteRenderers.length}"),
                }
              else
                {
                  print("TESTING else"),
                  print("peers else $peers"),
                }
            });

    socketIntilized.socket!.on("call_decline", (data) {
      print("call_decline data : $data");

      stopRingtone();
      getx.Get.find<ChatListController>().forChatList();
      getx.Get.offAll(
        TabbarScreen(
          currentTab: 0,
        ),
      );
      disposeLocalRender();
      disposeRemoteRender();
    });
  }

  void _endCall() {
    if (widget.isCaller == true) {
      isCallCutCall = true;
      setState(() {});
      stopRingtone();
    }
    if (isReciverConnect == false && widget.isCaller == true) {
      print("callCutByMe calling...");
      roomIdController.callCutByMe(
          conversationID: widget.conversation_id, callType: "video_call");
    }

    peers = {};
    socketIntilized.socket!
        .emit("leave-call", {"room_id": widget.roomID, "user_id": myPeer!.id});
    setState(() {
      inCall = false;
    });
    disposeLocalRender();
    disposeRemoteRender();
    getx.Get.find<ChatListController>().forChatList();
    getx.Get.offAll(
      TabbarScreen(
        currentTab: 0,
      ),
    );
  }

  bool microphone = false;
  void _toggleMicrophone() {
    microphone = !microphone;
    localRenderer.srcObject!.getAudioTracks()[0].enabled == true
        ? localRenderer.srcObject!.getAudioTracks()[0].enabled = false
        : localRenderer.srcObject!.getAudioTracks()[0].enabled = true;
    setState(() {});
  }

  bool camera = false;
  void _toggleCamera() {
    camera = !camera;
    localRenderer.srcObject!.getVideoTracks()[0].enabled == true
        ? localRenderer.srcObject!.getVideoTracks()[0].enabled = false
        : localRenderer.srcObject!.getVideoTracks()[0].enabled = true;
    setState(() {});
  }

  bool specker = false;
  void _toggleSpecker() async {
    specker == true
        ? await Helper.setSpeakerphoneOn(false)
        : await Helper.setSpeakerphoneOn(true);
    specker = !specker;
    setState(() {});
  }

  void _toggleScreenSize() {
    setState(() {
      isScreenBig = !isScreenBig;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleScreenSize,
      child: Scaffold(
        backgroundColor: appColorBlack,
        body: Stack(
          children: [
            remoteRenderers.length == 1
                ? forTwo()
                : remoteRenderers.length == 2
                    ? forThree()
                    : remoteRenderers.length == 3
                        ? forFour()
                        : remoteRenderers.length == 4
                            ? forFive()
                            : remoteRenderers.length > 4 &&
                                    remoteRenderers.length < 20
                                ? forSixToTwenty()
                                : forTwo(),
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.arrow_back,
                  ),
                  Text(
                    languageController.textTranslate('End-to-end encrypted'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: "Poppins",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      joinUsers();
                    },
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: appColorBlack.withOpacity(0.07),
                            ),
                            color: appColorBlack.withOpacity(0.10),
                          ),
                          child: Image.asset(
                            "assets/icons/profile-add.png",
                            height: 16,
                            width: 16,
                          ).paddingAll(9),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(38),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: appColorWhite.withOpacity(0.36),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        callOptionsContainer(
                          image: camera == false
                              ? "assets/icons/camera_on.png"
                              : "assets/icons/camera_off.png",
                          onTap: _toggleCamera,
                        ),
                        callOptionsContainer(
                          image: microphone == false
                              ? "assets/icons/mice_off.png"
                              : "assets/icons/mice_on.png",
                          onTap: _toggleMicrophone,
                        ),
                        callOptionsContainer(
                          image: specker == false
                              ? "assets/icons/volume_off.png"
                              : "assets/icons/volume_on.png",
                          onTap: _toggleSpecker,
                        ),
                        GestureDetector(
                          onTap: _endCall,
                          child: Image.asset(
                            "assets/icons/call_end.png",
                            height: 60,
                            width: 60,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  joinUsers() {
    return showDialog(
        context: context,
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        builder: (BuildContext context) {
          return const JoinedUsers();
        });
  }

  bool isSwap = false;
  int swapIndex = 0;

  Widget forSixToTwenty() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: RTCVideoView(
                  isSwap == true
                      ? remoteRenderers[
                          remoteRenderers.keys.elementAt(swapIndex)]!
                      : localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ],
        ),
        Positioned.fill(
          bottom: 110,
          top: getx.Get.height * 0.71,
          right: 20,
          child: ListView.builder(
            itemCount: remoteRenderers.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 250),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  isSwap = !isSwap;
                  swapIndex = index;
                  setState(() {});
                },
                child: Container(
                  height: 110,
                  width: 85,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorB0B0B0,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: RTCVideoView(
                      isSwap == true && index == swapIndex
                          ? localRenderer
                          : remoteRenderers[
                              remoteRenderers.keys.elementAt(index)]!,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ).paddingSymmetric(horizontal: 1),
              );
            },
          ),
        )
      ],
    );
  }

  Widget forFive() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      child: RTCVideoView(
                        remoteRenderers[remoteRenderers.keys.elementAt(0)]!,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      child: RTCVideoView(
                        remoteRenderers[remoteRenderers.keys.elementAt(1)]!,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: RTCVideoView(
                        remoteRenderers[remoteRenderers.keys.elementAt(2)]!,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: RTCVideoView(
                        remoteRenderers[remoteRenderers.keys.elementAt(3)]!,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 110,
          right: 20,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            child: SizedBox(
              height: 110,
              width: 85,
              child: RTCVideoView(
                localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget forFour() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(0)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(1)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(2)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget forThree() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: RTCVideoView(
              localRenderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(0)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(1)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget forTwo() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: RTCVideoView(
              localRenderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        ),
        remoteRenderers.isEmpty
            ? const SizedBox()
            : Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(0)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
      ],
    );
  }

  endedCall(BuildContext context) {
    return showDialog(
      barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            insetPadding: const EdgeInsets.all(8),
            alignment: Alignment.bottomCenter,
            backgroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            content: SizedBox(
              width: getx.Get.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    languageController
                        .textTranslate('This call has already ended.'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Text(
                    languageController.textTranslate('Please call again.'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            getx.Get.offAll(
                              TabbarScreen(
                                currentTab: 0,
                              ),
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: chatownColor, width: 1),
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                                child: Text(
                              languageController.textTranslate('Cancel'),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: chatColor),
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            getx.Get.offAll(
                              TabbarScreen(
                                currentTab: 0,
                              ),
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                    colors: [secondaryColor, chatownColor],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter)),
                            child: Center(
                                child: Text(
                              languageController.textTranslate('Call Again'),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: chatColor),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> disposeLocalRender() async {
    if (localRenderer.srcObject != null) {
      final audioTracks = localRenderer.srcObject!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        for (var track in audioTracks) {
          track.stop();
        }
      }

      final videoTracks = localRenderer.srcObject!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        for (var track in videoTracks) {
          track.stop();
        }
      }

      localRenderer.srcObject!.getAudioTracks().clear();
      localRenderer.srcObject!.getVideoTracks().clear();
    }

    await localRenderer.dispose();
  }

  Future<void> disposeRemoteRender() async {
    remoteRenderers.forEach((key, renderer) async {
      if (renderer.srcObject != null) {
        final audioTracks = renderer.srcObject!.getAudioTracks();
        if (audioTracks.isNotEmpty) {
          for (var track in audioTracks) {
            print('Stopping audio track for renderer $key');
            track.stop();
          }
        }

        final videoTracks = renderer.srcObject!.getVideoTracks();
        if (videoTracks.isNotEmpty) {
          for (var track in videoTracks) {
            print('Stopping video track for renderer $key');
            track.stop();
          }
        }

        renderer.srcObject!.getAudioTracks().clear();
        renderer.srcObject!.getVideoTracks().clear();
      } else {
        print('No srcObject found for renderer $key');
      }

      await renderer.dispose();
      print('Renderer $key disposed');
    });
  }

  @override
  void dispose() async {
    await disposeLocalRender();
    await disposeRemoteRender();
    if (myPeer != null) {
      myPeer!.dispose();
    }

    _delayedCheckFuture = Future.value();
    super.dispose();
  }
}
