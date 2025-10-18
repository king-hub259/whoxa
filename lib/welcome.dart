// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/screens/user/FinalLogin.dart';
import 'package:permission_handler/permission_handler.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  bool check = false;
  bool _requestingPermissions = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  // Future<void> requestPermissions() async {
  //   await Permission.notification.request();

  //   await Permission.location.request();

  //   await Permission.camera.request();

  //   await Permission.microphone.request();

  //   await Permission.storage.request();

  //   await Permission.photos.request();

  //   await Permission.contacts.request();
  // }

  Future<void> requestPermissions() async {
    // Prevent multiple simultaneous calls
    if (_requestingPermissions) return;

    _requestingPermissions = true;

    try {
      // Request each permission with a small delay in between
      await _requestPermissionWithDelay(Permission.notification);
      await _requestPermissionWithDelay(Permission.location);
      await _requestPermissionWithDelay(Permission.camera);
      await _requestPermissionWithDelay(Permission.microphone);
      await _requestPermissionWithDelay(Permission.storage);
      await _requestPermissionWithDelay(Permission.photos);
      await _requestPermissionWithDelay(Permission.contacts);
    } catch (e) {
      print("Permission request error: $e");
    } finally {
      _requestingPermissions = false;
    }
  }

  Future<void> _requestPermissionWithDelay(Permission permission) async {
    try {
      final status = await permission.request();
      print("Permission ${permission.toString()} status: $status");
      // Wait a short time before requesting the next permission
      await Future.delayed(Duration(milliseconds: 300));
    } catch (e) {
      print("Error requesting ${permission.toString()}: $e");
      // Still add delay even if there's an error
      await Future.delayed(Duration(milliseconds: 300));
      // Rethrow if you want to handle this at a higher level
      // rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // void handleURLButtonPress(BuildContext context, String url) {
    //   debugPrint("url ");
    //   Navigator.push(context,
    //       MaterialPageRoute(builder: (context) => PrivacyWebView(url: url)));
    // }

    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Flogin()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xffFFFFFF),
        body: Stack(
          children: [
            Image.asset(
              "assets/images/splash_screen_2.png",
              height: Get.height,
              width: Get.height,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Column(
                children: [
                  sizeBoxHeight(137),
                  Text(
                    languageController.textTranslate(
                        languageController.appSettingsData[0].appName!),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                  sizeBoxHeight(340),
                  Text(
                    languageController.textTranslate(
                        "Chat effortlessly with friends and family anytime, anywhere!"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w500),
                  ).paddingSymmetric(horizontal: 25),
                  sizeBoxHeight(17),
                  Text(
                    languageController
                        .textTranslate("Share photos and chat anytime."),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ).paddingSymmetric(horizontal: 25),
                ],
              ),
            ),
            Positioned(
              bottom: getProportionateScreenHeight(-32),
              right: getProportionateScreenWidth(-28),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: getProportionateScreenHeight(220),
                    width: getProportionateScreenWidth(220),
                    decoration: const BoxDecoration(
                      color: appColorWhite,
                      shape: BoxShape.circle,
                    ),
                    // child: const CircleAvatar(
                    //   radius: 100,
                    //   backgroundImage: AssetImage(
                    //     "assets/images/start_chat.gif",
                    //   ),
                    //   backgroundColor: Colors.transparent,
                    // ),
                  ),
                  const Center(
                    child: CircleAvatar(
                      radius: 87,
                      backgroundImage: AssetImage(
                        "assets/images/start_chat.gif",
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      "assets/images/arrow_right.png",
                      scale: 4,
                    ),
                  ),
                  Positioned.fill(
                      bottom: getProportionateScreenHeight(20),
                      right: getProportionateScreenWidth(20),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: getProportionateScreenHeight(30),
                          width: getProportionateScreenWidth(30),
                          color: appColorWhite,
                          child: SizedBox(),
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
