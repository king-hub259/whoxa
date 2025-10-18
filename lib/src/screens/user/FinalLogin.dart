// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_print, no_leading_underscores_for_local_identifiers, prefer_final_fields, unused_field, file_names, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:whoxachat/src/screens/user/otp.dart';
import 'package:whoxachat/src/screens/user/pp_and_tc_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

final ApiHelper apiHelper = ApiHelper();

class Flogin extends StatefulWidget {
  const Flogin({super.key});

  static String verify = "";

  @override
  State<Flogin> createState() => _FloginState();
}

class _FloginState extends State<Flogin> with SingleTickerProviderStateMixin {
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  GlobalKey<FormState> myKey5 = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  Country? _selectedCountry;
  Timer? _timer;
  int _counter = 0;
  String selectedCountry = 'United States of America';
  String selectedCountrycode = '+1';
  String selectedCountrySortName = 'US';
  String selectedCountryimg = '';
  int maxLength = 10;
  late TextEditingController controller;
  late bool autoFocus;
  int start = 60;
  bool wait = false;
  String _code = "";
  bool isLoading = false;
  bool isLoading2 = false;
  StreamController<int>? _events;

  late TabController _tabController;
  int _currentTabIndex = 0;

  void initCountry() async {
    Timer? _timer;
    int _counter = 0;
    Country? _selectedCountry;
    StreamController<int>? _events;
    final country = await getDefaultCountry(context);
    setState(() {
      _selectedCountry = country;
    });
    requestPermissions();
  }

  String mobileNumber = '';
  int? lengthNum;
  bool check = false;

  Future<void> requestPermissions() async {
    await Permission.notification.request();

    // await Permission.location.request();

    await Permission.camera.request();

    await Permission.microphone.request();

    await Permission.storage.request();

    await Permission.photos.request();

    await Permission.contacts.request();
  }

  void _startTimer() {
    _counter = 60;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      (_counter > 0) ? _counter-- : _timer!.cancel();

      print(_counter);
      _events!.add(_counter);
    });
  }

  oTPcaLL() async {
    try {
      if (phoneController.text.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        var uri = Uri.parse(apiHelper.registerPhone);
        var request = http.MultipartRequest("POST", uri);
        Map<String, String> headers = {
          "Accept": "application/json",
        };
        request.headers.addAll(headers);
        print("URL: ${apiHelper.registerPhone}");
        request.fields['country_code'] = selectedCountrycode;
        request.fields['phone_number'] = phoneController.text;
        request.fields['country_full_name'] = selectedCountry;
        request.fields['country'] = selectedCountrySortName;

        print("FIELDS:${request.fields}");
        var response = await request.send();
        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
            _startTimer();
          });

          startTimer();

          showCustomToast(
              languageController.textTranslate('OTP SENT SUCESSFULLY'));

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => otp(
                  phoneController: phoneController.text,
                  selectedCountry: selectedCountrycode,
                  countryName: selectedCountry,
                  varify: "",
                  inWhichScreen: 'Mobile screen',
                ),
              ));
        } else {
          setState(() {
            isLoading = false;
          });

          showCustomToast(
              languageController.textTranslate('Enter valid Phone number'));
        }
      } else {
        setState(() {
          isLoading = false;
        });

        showCustomToast(languageController.textTranslate('Enter Phone number'));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      Get.snackbar(
          "Error",
          languageController
              .textTranslate('Something went wrong while sending OTP'));
    }
  }

  // Add this method to your _FloginState class
  emailLogin() async {
    try {
      if (emailController.text.isNotEmpty) {
        setState(() {
          isLoading = true;
        });

        // Email validation
        if (!RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(emailController.text)) {
          setState(() {
            isLoading = false;
          });
          showCustomToast(
              languageController.textTranslate('Enter valid Email'));
          return;
        }

        var uri = Uri.parse(apiHelper.registerEmail);
        var request = http.MultipartRequest("POST", uri);
        Map<String, String> headers = {
          "Accept": "application/json",
        };
        request.headers.addAll(headers);

        // Add email_id field as shown in your Postman screenshot
        request.fields['email_id'] = emailController.text;

        print("FIELDS:${request.fields}");
        var response = await request.send();

        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
            _startTimer();
          });

          startTimer();
          showCustomToast(
              languageController.textTranslate('OTP SENT SUCCESSFULLY'));

          // Navigate to OTP verification screen
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => otp(
                  phoneController: '',
                  email: emailController,
                  selectedCountry: '',
                  countryName: '',
                  varify: "",
                  inWhichScreen: 'Email screen',
                ),
              ));
        } else {
          setState(() {
            isLoading = false;
          });
          // Print the status code
          print('Response status code: ${response.statusCode}');

          // Read and process the response body from the stream
          response.stream.bytesToString().then((bodyString) {
            print('Response body: $bodyString');

            // Parse the JSON response to extract the error message
            try {
              Map<String, dynamic> responseData = jsonDecode(bodyString);
              String errorMessage = responseData['message'] ?? 'Request failed';

              // Show the error message in the toast
              showCustomToast(languageController.textTranslate(errorMessage));
            } catch (e) {
              // If JSON parsing fails, show a generic message
              showCustomToast(languageController
                  .textTranslate('Request failed: ${response.statusCode}'));
            }
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        showCustomToast(languageController.textTranslate('Enter Email'));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      Get.snackbar(
          "Error",
          languageController
              .textTranslate('Something went wrong while sending OTP'));
    }
  }

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  // @override
  // initState() {
  //   _events = StreamController<int>();
  //   _events!.add(60);

  //   _tabController = TabController(length: 2, vsync: this);
  //   _tabController.addListener(() {
  //     setState(() {
  //       _currentTabIndex = _tabController.index;
  //     });
  //   });

  //   super.initState();
  //   print(start);
  //   initCountry();
  // }

  @override
  initState() {
    _events = StreamController<int>();
    _events!.add(60);

    // Get the number of enabled authentication methods
    int tabCount = 0;
    if (languageController.appSettingsData.isNotEmpty) {
      if (languageController.appSettingsData[0].phoneAuth == true) tabCount++;
      if (languageController.appSettingsData[0].emailAuth == true) tabCount++;
    }

    // Ensure there's at least one tab
    tabCount = tabCount > 0 ? tabCount : 1;

    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    super.initState();
    print(start);
    initCountry();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: appColorWhite,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: myKey5,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: appColorWhite,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: header(),
                ),
              ),
              const SizedBox(height: 10),
              if (Platform.isIOS) button() else button(),
              const SizedBox(height: 35),
              // Obx(
              //   () => languageController.appSettingsData[0].demoCredentials ==
              //           false
              //       ? const SizedBox.shrink()
              //       : Stack(
              //           children: [
              //             Container(
              //               width: Get.width,
              //               decoration: BoxDecoration(
              //                 color: secondaryColor,
              //                 borderRadius: BorderRadius.circular(10),
              //               ),
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   const SizedBox(
              //                     height: 10,
              //                   ),
              //                   Text(
              //                     languageController.textTranslate('For Demo'),
              //                     style: const TextStyle(
              //                         fontSize: 15,
              //                         fontWeight: FontWeight.w700,
              //                         fontFamily: 'Poppins'),
              //                   ).paddingSymmetric(horizontal: 26),
              //                   const SizedBox(
              //                     height: 6,
              //                   ),
              //                   const Divider(
              //                     color: Color(0xffD8D8D8),
              //                   ),
              //                   const SizedBox(
              //                     height: 10,
              //                   ),
              //                   Text(
              //                     languageController.textTranslate(
              //                         'Mobile Number: +1 5628532467'),
              //                     style: const TextStyle(
              //                       fontSize: 14,
              //                       fontWeight: FontWeight.w500,
              //                       fontFamily: 'Poppins',
              //                     ),
              //                   ).paddingSymmetric(horizontal: 26),
              //                   const SizedBox(
              //                     height: 10,
              //                   ),
              //                   Text(
              //                     languageController
              //                         .textTranslate('OTP: 123456'),
              //                     style: const TextStyle(
              //                       fontSize: 14,
              //                       fontWeight: FontWeight.w500,
              //                       fontFamily: 'Poppins',
              //                     ),
              //                   ).paddingSymmetric(horizontal: 26),
              //                   const SizedBox(
              //                     height: 12,
              //                   ),
              //                 ],
              //               ),
              //             ).paddingSymmetric(horizontal: 20),
              //             Positioned.fill(
              //               top: 8,
              //               right: 35,
              //               child: Align(
              //                 alignment: Alignment.centerRight,
              //                 child: GestureDetector(
              //                   onTap: () {
              //                     phoneController.text = "5628532467";
              //                     setState(() {});
              //                   },
              //                   child: Image.asset(
              //                     "assets/icons/copy.png",
              //                     scale: 4,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              // ),
              Obx(
                () => languageController.appSettingsData[0].demoCredentials ==
                        false
                    ? const SizedBox.shrink()
                    : Stack(
                        children: [
                          Container(
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  languageController.textTranslate('For Demo'),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins'),
                                ).paddingSymmetric(horizontal: 26),
                                const SizedBox(height: 6),
                                const Divider(color: Color(0xffD8D8D8)),
                                const SizedBox(height: 10),
                                // Show different credential text based on selected tab
                                Text(
                                  _currentTabIndex == 0
                                      ? languageController.textTranslate(
                                          'Mobile Number: +1 5628532467')
                                      : languageController.textTranslate(
                                          'Email: whoxa@demo.com'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ).paddingSymmetric(horizontal: 26),
                                const SizedBox(height: 10),
                                Text(
                                  languageController
                                      .textTranslate('OTP: 123456'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ).paddingSymmetric(horizontal: 26),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ).paddingSymmetric(horizontal: 20),
                          Positioned.fill(
                            top: 8,
                            right: 35,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  // Copy different data based on selected tab
                                  if (_currentTabIndex == 0) {
                                    phoneController.text = "5628532467";
                                  } else {
                                    emailController.text = "whoxa@demo.com";
                                  }
                                  setState(() {});
                                },
                                child: Image.asset(
                                  "assets/icons/copy.png",
                                  scale: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget button() {
  //   return Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //       child: isLoading
  //           ? Center(
  //               child: SizedBox(
  //               height: 30,
  //               width: 30,
  //               child: CircularProgressIndicator(color: chatownColor),
  //             ))
  //           : CustomButtom(
  //               onPressed: () {
  //                 if (check == true) {
  //                   log("MOBILE_NUM:${selectedCountrycode + phoneController.text}");
  //                   if (myKey5.currentState!.validate()) {
  //                     setState(() {
  //                       isLoading = true;
  //                     });
  //                     oTPcaLL();
  //                   } else {
  //                     Fluttertoast.showToast(
  //                         msg: languageController
  //                             .textTranslate('Enter valid mobile number'));
  //                   }
  //                 } else {
  //                   Fluttertoast.showToast(
  //                       msg: languageController.textTranslate(
  //                           'Allow check to continue privacy policy and term condition'),
  //                       backgroundColor: Colors.black,
  //                       textColor: appColorWhite);
  //                 }
  //               },
  //               title: languageController.textTranslate('Send OTP'),
  //             ));
  // }

  // Widget button() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //     child: isLoading
  //         ? Center(
  //             child: SizedBox(
  //             height: 30,
  //             width: 30,
  //             child: CircularProgressIndicator(color: chatownColor),
  //           ))
  //         : CustomButtom(
  //             onPressed: () {
  //               if (check == true) {
  //                 if (_currentTabIndex == 0) {
  //                   // Phone login logic
  //                   log("MOBILE_NUM:${selectedCountrycode + phoneController.text}");
  //                   if (myKey5.currentState!.validate()) {
  //                     setState(() {
  //                       isLoading = true;
  //                     });
  //                     oTPcaLL();
  //                   } else {
  //                     Fluttertoast.showToast(
  //                         msg: languageController
  //                             .textTranslate('Enter valid mobile number'));
  //                   }
  //                 } else {
  //                   // Email login logic
  //                   log("EMAIL:${emailController.text}");
  //                   if (emailController.text.isNotEmpty) {
  //                     // Simple email validation
  //                     if (!RegExp(
  //                             r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
  //                         .hasMatch(emailController.text)) {
  //                       Fluttertoast.showToast(
  //                           msg: languageController
  //                               .textTranslate('Enter valid email'));
  //                       return;
  //                     }
  //                     setState(() {
  //                       isLoading = true;
  //                     });
  //                     emailLogin();
  //                   } else {
  //                     Fluttertoast.showToast(
  //                         msg: languageController.textTranslate('Enter email'));
  //                   }
  //                 }
  //               } else {
  //                 Fluttertoast.showToast(
  //                     msg: languageController.textTranslate(
  //                         'Allow check to continue privacy policy and term condition'),
  //                     backgroundColor: Colors.black,
  //                     textColor: appColorWhite);
  //               }
  //             },
  //             title: languageController.textTranslate('Send OTP'),
  //           ),
  //   );
  // }

  Widget button() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: isLoading
          ? Center(
              child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(color: chatownColor),
            ))
          : CustomButtom(
              onPressed: () {
                if (check == true) {
                  // Get the current tab type
                  String currentAuthType = '';

                  if (languageController.appSettingsData.isNotEmpty) {
                    if (languageController.appSettingsData[0].phoneAuth ==
                            true &&
                        languageController.appSettingsData[0].emailAuth ==
                            true) {
                      // Both auth types are enabled
                      currentAuthType =
                          _currentTabIndex == 0 ? 'phone' : 'email';
                    } else if (languageController
                            .appSettingsData[0].phoneAuth ==
                        true) {
                      // Only phone auth is enabled
                      currentAuthType = 'phone';
                    } else if (languageController
                            .appSettingsData[0].emailAuth ==
                        true) {
                      // Only email auth is enabled
                      currentAuthType = 'email';
                    } else {
                      // Default to phone if nothing is enabled
                      currentAuthType = 'phone';
                    }
                  } else {
                    // Default to phone if settings aren't loaded
                    currentAuthType = 'phone';
                  }

                  if (currentAuthType == 'phone') {
                    // Phone login logic
                    log("MOBILE_NUM:${selectedCountrycode + phoneController.text}");
                    if (myKey5.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      oTPcaLL();
                    } else {
                      Fluttertoast.showToast(
                          msg: languageController
                              .textTranslate('Enter valid mobile number'));
                    }
                  } else {
                    // Email login logic
                    log("EMAIL:${emailController.text}");
                    if (emailController.text.isNotEmpty) {
                      // Simple email validation
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(emailController.text)) {
                        Fluttertoast.showToast(
                            msg: languageController
                                .textTranslate('Enter valid email'));
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      emailLogin();
                    } else {
                      Fluttertoast.showToast(
                          msg: languageController.textTranslate('Enter email'));
                    }
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: languageController.textTranslate(
                          'Allow check to continue privacy policy and term condition'),
                      backgroundColor: Colors.black,
                      textColor: appColorWhite);
                }
              },
              title: languageController.textTranslate('Send OTP'),
            ),
    );
  }

  Widget header() {
    var country = _selectedCountry;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.09),
            ),
          ),
          Image.network(
            languageController.appSettingsData[0].appLogo!,
            height: 90,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 15),
          Image.asset("assets/images/welcome.png", height: 44),
          const SizedBox(height: 8),
          Text(
            languageController.textTranslate('Hello welcome to chat app'),
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 34),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  // TabBar(
                  //   controller: _tabController,
                  //   indicator: UnderlineTabIndicator(
                  //     borderSide: BorderSide(
                  //       width: 2.0,
                  //       color: Colors.amber,
                  //     ),
                  //     insets: EdgeInsets.symmetric(horizontal: 30.0),
                  //   ),
                  //   labelColor: Colors.black,
                  //   unselectedLabelColor: Colors.grey.shade600,
                  //   unselectedLabelStyle: TextStyle(
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.normal,
                  //   ),
                  //   labelStyle: const TextStyle(
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  //   indicatorSize: TabBarIndicatorSize.tab,
                  //   dividerColor: Colors.transparent,
                  //   tabs: const [
                  //     Tab(text: 'Phone'),
                  //     Tab(text: 'Email'),
                  //   ],
                  // ),
                  // First, modify the TabBar in your header() widget to be conditional
                  TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: Colors.amber,
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 30.0),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade600,
                    unselectedLabelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: _getTabs(),
                  ),
                  const SizedBox(height: 30),
                  // TabBarView content to hold phone and email inputs
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 20),
                  //   height: _currentTabIndex == 0 ? 150 : 150,
                  //   child: TabBarView(
                  //     controller: _tabController,
                  //     physics:
                  //         const NeverScrollableScrollPhysics(), // Prevent swiping
                  //     children: [
                  //       // Phone tab content
                  //       phoneLoginWidget(),
                  //       // Email tab content
                  //       emailLoginWidget(),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    height: 150,
                    child: TabBarView(
                      controller: _tabController,
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevent swiping
                      children: _getTabViews(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                        onTap: () {
                          setState(() {
                            check = !check;
                          });
                        },
                        child: check == true
                            ? selectedContainer()
                            : unSelectedContainer())
                    .paddingOnly(top: 4),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Obx(
                      () => Text.rich(
                        TextSpan(
                          text:
                              "${languageController.textTranslate('To continue, check')} ",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins'),
                          children: [
                            TextSpan(
                              text: languageController
                                  .textTranslate('Privacy Policy'),
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 1.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(PpAndTcScreen());
                                  // handleURLButtonPress(
                                  //     context, "${baseUrl()}get-privacy-policy");
                                },
                            ),
                            TextSpan(
                              text:
                                  " ${languageController.textTranslate('and')} ",
                            ),
                            TextSpan(
                              text: languageController
                                  .textTranslate('Terms & Conditions.'),
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 1.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(PpAndTcScreen(
                                    isFromPP: false,
                                  ));
                                  // handleURLButtonPress(
                                  //     context, "${baseUrl()}get-tncs");
                                },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingOnly(left: 0, right: 60),
          ),
        ],
      ),
    );
  }

  //get tab dynamically
  List<Widget> _getTabs() {
    List<Widget> tabs = [];

    // Only add the Phone tab if phoneAuth is true
    if (languageController.appSettingsData.isNotEmpty &&
        languageController.appSettingsData[0].phoneAuth == true) {
      tabs.add(Tab(text: 'Phone'));
    }

    // Only add the Email tab if emailAuth is true
    if (languageController.appSettingsData.isNotEmpty &&
        languageController.appSettingsData[0].emailAuth == true) {
      tabs.add(Tab(text: 'Email'));
    }

    // If no auth methods are enabled, still show at least one tab
    if (tabs.isEmpty) {
      tabs.add(Tab(text: 'Phone'));
    }

    return tabs;
  }

  //dynamic tabview
  List<Widget> _getTabViews() {
    List<Widget> views = [];

    // Only add the phone login widget if phoneAuth is true
    if (languageController.appSettingsData.isNotEmpty &&
        languageController.appSettingsData[0].phoneAuth == true) {
      views.add(phoneLoginWidget());
    }

    // Only add the email login widget if emailAuth is true
    if (languageController.appSettingsData.isNotEmpty &&
        languageController.appSettingsData[0].emailAuth == true) {
      views.add(emailLoginWidget());
    }

    // If no auth methods are enabled, still show at least one view
    if (views.isEmpty) {
      views.add(phoneLoginWidget());
    }

    return views;
  }

  Widget selectedContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 16,
      width: 16,
      decoration: BoxDecoration(
        // shape: BoxShape.circle,
        borderRadius: BorderRadius.circular(2),
        color: appColorBlack,
      ),
      child: Image.asset(
        "assets/images/check.png",
        scale: 2,
        color: appColorWhite,
      ).paddingAll(3),
    );
  }

  Widget unSelectedContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 16,
      width: 16,
      decoration: BoxDecoration(
          // shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(width: 1, color: appColorBlack)),
    );
  }

  // void _onPressedShowBottomSheet() async {
  //   final country = await showCountryPickerSheet(

  //     context,
  //   );
  //   if (country != null) {
  //     setState(() {
  //       selectedCountrycode = country.callingCode;
  //       selectedCountry = country.name;
  //       selectedCountrySortName = country.countryCode;

  //       debugPrint("selectedCountry SortName $selectedCountrySortName");
  //       debugPrint("selectedCountry Name ${country.name}");

  //       _selectedCountry = country;

  //       maxLength = countryMobileLengths[selectedCountrycode] ?? 10;
  //     });
  //   }
  // }

  void _onPressedShowBottomSheet() async {
    // First, complete the current build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Create a custom theme with white color
      final customTheme = Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.white,
              secondary: Colors.white,
              background: Colors.white,
              surface: Colors.white,
            ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          // Default (unfocused) borders
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(176, 176, 176, 1),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          // Focused borders - change color here
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: chatownColor, // Your highlight color
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          // Error borders
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          // Focused error borders
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dialogBackgroundColor: Colors.white,
      );

      // Use showModalBottomSheet instead of directly calling showCountryPickerSheet
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        builder: (BuildContext bottomSheetContext) {
          // Apply the theme to the content inside the bottom sheet
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: customTheme,
              child: CountryPickerWidget(
                onSelected: (Country country) {
                  Navigator.pop(context, country);
                  // Process the selected country
                  setState(() {
                    selectedCountrycode = country.callingCode;
                    selectedCountry = country.name;
                    selectedCountrySortName = country.countryCode;
                    _selectedCountry = country;
                    maxLength = countryMobileLengths[selectedCountrycode] ?? 10;
                  });
                  print(selectedCountrycode);
                },
              ),
            ),
          );
        },
      );
    });
  }

  void startTimer() {
    print("--------------------->>>>>>>");
    const onsec = Duration(seconds: 1);
    Timer _timer = Timer.periodic(onsec, (timer) {
      print(start);
      if (start == 0) {
        timer.cancel();
        wait = false;
      } else {
        start--;
      }
    });
  }

  Future sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '$selectedCountrycode${phoneController.text}',
      verificationCompleted: (PhoneAuthCredential credential) {
        setState(() {
          isLoading = false;
        });
      },
      timeout: const Duration(seconds: 30),
      verificationFailed: (FirebaseAuthException e) {
        Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        Flogin.verify = verificationId;
        if (kDebugMode) {
          print('PHONE PAGE VARIFI::::$verificationId');
        }
        Fluttertoast.showToast(
            msg: languageController.textTranslate('OTP sent Succesfully'));
        setState(() {
          isLoading = false;
        });

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => otp(
                phoneController: phoneController.text,
                selectedCountry: selectedCountrycode,
                countryName: selectedCountry,
                varify: verificationId,
                inWhichScreen: 'Mobile screen',
              ),
            ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Widget phoneLoginWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              languageController.textTranslate('Mobile Number'),
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  fontFamily: 'Poppins'),
            )),
        const SizedBox(height: 10),
        Row(
          children: [
            // Country code selector
            Container(
              height: 47,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
                border:
                    Border.all(color: const Color.fromRGBO(176, 176, 176, 1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: InkWell(
                      onTap: () {
                        _onPressedShowBottomSheet();
                      },
                      child: Row(
                        children: [
                          Text(
                            selectedCountrycode,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_drop_down,
                            color: chatownColor,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Phone number field
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
                  border: Border(
                      top: BorderSide(color: Color.fromRGBO(176, 176, 176, 1)),
                      right:
                          BorderSide(color: Color.fromRGBO(176, 176, 176, 1)),
                      bottom:
                          BorderSide(color: Color.fromRGBO(176, 176, 176, 1))),
                ),
                child: SizedBox(
                  height: 45,
                  child: TextField(
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500),
                      cursorColor: Colors.black,
                      onChanged: (value) {
                        setState(() {
                          mobileNumber = value;
                        });
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(maxLength),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.only(top: 1, left: 4, bottom: 1),
                        hintStyle: TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
              languageController.textTranslate(
                  'We will send you 6 digit code on the given phone number'),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins')),
        ),
      ],
    );
  }

  Widget emailLoginWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              languageController.textTranslate('Email'),
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  fontFamily: 'Poppins'),
            )),
        const SizedBox(height: 10),
        Container(
          height: 47,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromRGBO(176, 176, 176, 1)),
          ),
          child: TextField(
            style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
            cursorColor: Colors.black,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
              hintText: languageController.textTranslate('Enter your email'),
              hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400),
              filled: true,
              fillColor: Colors.transparent,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
              languageController.textTranslate(
                  'We will send you 6 digit code on the given email'),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}
