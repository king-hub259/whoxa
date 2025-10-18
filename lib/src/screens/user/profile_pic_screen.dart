// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/avatar_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whoxachat/Models/user_profile_model.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:page_transition/page_transition.dart';

class ProfilePicScreen extends StatefulWidget {
  const ProfilePicScreen({super.key});

  @override
  State<ProfilePicScreen> createState() => _ProfilePicScreenState();
}

class _ProfilePicScreenState extends State<ProfilePicScreen> {
  AvatarController avatarController = Get.put(AvatarController());

  @override
  void initState() {
    super.initState();
    avatarController.avatarIndex.value = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: const Color.fromRGBO(250, 250, 250, 1),
        child: Stack(
          children: [
            SizedBox(
              height: Get.height * 0.27,
              width: double.infinity,
              child: Image.asset(
                cacheHeight: 140,
                "assets/images/back_img1.png",
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 25, right: 25, bottom: 20, top: Get.height * 0.13),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _imgWidget(),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 37,
                        ),
                        chooseAvatar(),
                        const SizedBox(
                          height: 31,
                        ),
                        orField(),
                        const SizedBox(
                          height: 31,
                        ),
                        pickImage(),
                        const SizedBox(
                          height: 42,
                        ),
                        buttonClick
                            ? Center(
                                child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                    color: chatownColor),
                              ))
                            : CustomButtom(
                                onPressed: () {
                                  closekeyboard();
                                  editApiCall();
                                },
                                title: "Submit",
                              )
                      ],
                    ),
                  ))
                ],
              ),
            ),
            const Positioned(
                top: 45,
                left: 15,
                child: Text(
                  "Select Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                )),
          ],
        ),
      ),
    );
  }

  Widget chooseAvatar() {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF),
        border: Border.all(
          width: 1,
          color: const Color(0xffEFEFEF),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 17,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose Avtar',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  color: Color(0xff000000)),
            ),
          ),
          const SizedBox(
            height: 33,
          ),
          SizedBox(
            height: 80,
            child: Obx(
              () => ListView.builder(
                itemCount: avatarController.avatarsData.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Obx(
                    () => avatarController
                            .avatarsData[index].avtarMedia!.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              image = null;
                              setState(() {});
                              avatarController.avatarIndex.value = index;
                            },
                            child: profileImg == "https://whoxachat.com/uploads/not-found-images/profile-image.png" &&
                                    image == null &&
                                    Hive.box(userdata).get(userGender) ==
                                        "male" &&
                                    avatarController
                                            .avatarsData[index].avatarGender! ==
                                        "male" &&
                                    avatarController
                                            .avatarsData[index].defaultAvtar! ==
                                        true &&
                                    avatarController.avatarIndex.value == -1
                                ? Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: chatownColor, width: 2),
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: CachedNetworkImage(
                                            imageUrl: avatarController
                                                .avatarsData[index].avtarMedia!,
                                            errorWidget: (context, url,
                                                    error) =>
                                                Container(
                                                  height: 75,
                                                  width: 75,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color:
                                                              Color(0XFFE7B12D),
                                                          shape:
                                                              BoxShape.circle),
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 20,
                                                    color: Colors.black,
                                                  ),
                                                )).paddingSymmetric(
                                            horizontal: index == 0 ? 0 : 7),
                                      ),
                                      Positioned(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: appColorWhite,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                    colors: [
                                                      secondaryColor,
                                                      chatownColor
                                                    ])),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              size: 13,
                                            ).paddingAll(3),
                                          ).paddingAll(4),
                                        ),
                                      )
                                    ],
                                  )
                                : profileImg == "https://whoxachat.com/uploads/not-found-images/profile-image.png" &&
                                        image == null &&
                                        Hive.box(userdata)
                                                .get(userGender) ==
                                            "female" &&
                                        avatarController.avatarsData[index]
                                                .avatarGender! ==
                                            "female" &&
                                        avatarController.avatarsData[index]
                                                .defaultAvtar! ==
                                            true &&
                                        avatarController.avatarIndex.value == -1
                                    ? Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: chatownColor,
                                                  width: 2),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: CachedNetworkImage(
                                                imageUrl: avatarController
                                                    .avatarsData[index]
                                                    .avtarMedia!,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                          height: 75,
                                                          width: 75,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  color: Color(
                                                                      0XFFE7B12D),
                                                                  shape: BoxShape
                                                                      .circle),
                                                          child: const Icon(
                                                            Icons.person,
                                                            size: 20,
                                                            color: Colors.black,
                                                          ),
                                                        )).paddingSymmetric(
                                                horizontal: index == 0 ? 0 : 7),
                                          ),
                                          Positioned(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: appColorWhite,
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          secondaryColor,
                                                          chatownColor
                                                        ])),
                                                child: const Icon(
                                                  Icons.check_rounded,
                                                  size: 13,
                                                ).paddingAll(3),
                                              ).paddingAll(4),
                                            ),
                                          )
                                        ],
                                      )
                                    : avatarController.avatarIndex.value != -1 &&
                                            avatarController.avatarIndex.value ==
                                                index
                                        ? Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: chatownColor,
                                                      width: 2),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: CachedNetworkImage(
                                                    imageUrl: avatarController
                                                        .avatarsData[index]
                                                        .avtarMedia!,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Container(
                                                          height: 75,
                                                          width: 75,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  color: Color(
                                                                      0XFFE7B12D),
                                                                  shape: BoxShape
                                                                      .circle),
                                                          child: const Icon(
                                                            Icons.person,
                                                            size: 20,
                                                            color: Colors.black,
                                                          ),
                                                        )).paddingSymmetric(
                                                    horizontal:
                                                        index == 0 ? 0 : 7),
                                              ),
                                              Positioned(
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: appColorWhite,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient:
                                                            LinearGradient(
                                                                colors: [
                                                              secondaryColor,
                                                              chatownColor
                                                            ])),
                                                    child: const Icon(
                                                      Icons.check_rounded,
                                                      size: 13,
                                                    ).paddingAll(3),
                                                  ).paddingAll(4),
                                                ),
                                              )
                                            ],
                                          )
                                        : profileImg!.isNotEmpty &&
                                                profileImg !=
                                                    "https://whoxachat.com/uploads/not-found-images/profile-image.png" &&
                                                avatarController.avatarsData
                                                    .where((avatar) =>
                                                        avatar.avtarMedia ==
                                                        profileImg)
                                                    .map((avatar) =>
                                                        avatar.avtarMedia!)
                                                    .isNotEmpty &&
                                                profileImg ==
                                                    avatarController
                                                        .avatarsData[index]
                                                        .avtarMedia &&
                                                avatarController.avatarIndex.value ==
                                                    -1 &&
                                                image == null
                                            ? Stack(
                                                alignment:
                                                    Alignment.bottomRight,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: chatownColor,
                                                          width: 2),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: CachedNetworkImage(
                                                        imageUrl:
                                                            avatarController
                                                                .avatarsData[
                                                                    index]
                                                                .avtarMedia!,
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                              height: 75,
                                                              width: 75,
                                                              decoration: const BoxDecoration(
                                                                  color: Color(
                                                                      0XFFE7B12D),
                                                                  shape: BoxShape
                                                                      .circle),
                                                              child: const Icon(
                                                                Icons.person,
                                                                size: 20,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            )).paddingSymmetric(
                                                        horizontal:
                                                            index == 0 ? 0 : 7),
                                                  ),
                                                  Positioned(
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: appColorWhite,
                                                      ),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            gradient:
                                                                LinearGradient(
                                                                    colors: [
                                                                  secondaryColor,
                                                                  chatownColor
                                                                ])),
                                                        child: const Icon(
                                                          Icons.check_rounded,
                                                          size: 13,
                                                        ).paddingAll(3),
                                                      ).paddingAll(4),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Container(
                                                child: CachedNetworkImage(
                                                    imageUrl: avatarController
                                                        .avatarsData[index]
                                                        .avtarMedia!,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Container(
                                                          height: 75,
                                                          width: 75,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  color: Color(
                                                                      0XFFE7B12D),
                                                                  shape: BoxShape
                                                                      .circle),
                                                          child: const Icon(
                                                            Icons.person,
                                                            size: 20,
                                                            color: Colors.black,
                                                          ),
                                                        )).paddingSymmetric(
                                                    horizontal:
                                                        index == 0 ? 0 : 7),
                                              ),
                          )
                        : Container(
                            height: 75,
                            width: 75,
                            decoration: const BoxDecoration(
                                color: Color(0XFFE7B12D),
                                shape: BoxShape.circle),
                            child: const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 33,
          ),
        ],
      ).paddingSymmetric(horizontal: 18),
    );
  }

  Widget _imgWidget() {
    return Container(
      height: 110,
      width: 110,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            userImg(),
          ],
        ),
      ),
    );
  }

  String? profileImg;
  Widget userImg() {
    profileImg;
    if (checkForNull(Hive.box(userdata).get(userImage)) != null) {
      profileImg = Hive.box(userdata).get(userImage);
    }
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 110,
        width: 110,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 0.0))
            ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(110),
            child: profileImg != null &&
                    profileImg !=
                        "https://whoxachat.com/uploads/not-found-images/profile-image.png" &&
                    avatarController.avatarIndex.value == -1 &&
                    image == null
                ? avatarController.avatarsData
                        .where((avatar) => avatar.avtarMedia == profileImg)
                        .map((avatar) => avatar.avtarMedia!)
                        .isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profileImg!,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person, color: chatColor),
                      )
                    : CachedNetworkImage(
                        imageUrl: profileImg!,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person, color: chatColor),
                      )
                : image == null
                    // ? Obx(
                    //     () => avatarController.avatarIndex.value != -1
                    //         ? CachedNetworkImage(
                    //             imageUrl: avatarController
                    //                 .avatarsData[
                    //                     avatarController.avatarIndex.value]
                    //                 .avtarMedia!,
                    //             imageBuilder: (context, imageProvider) =>
                    //                 Container(
                    //               decoration: BoxDecoration(
                    //                 shape: BoxShape.circle,
                    //                 image: DecorationImage(
                    //                   image: imageProvider,
                    //                   fit: BoxFit.cover,
                    //                 ),
                    //               ),
                    //             ),
                    //             errorWidget: (context, url, error) =>
                    //                 const Icon(Icons.person, color: chatColor),
                    //           )
                    //         : Hive.box(userdata).get(userGender) == "male"
                    //             ? CachedNetworkImage(
                    //                 imageUrl: avatarController.avatarsData
                    //                     .where((avatar) =>
                    //                         avatar.avatarGender == "male" &&
                    //                         avatar.defaultAvtar == true)
                    //                     .map((avatar) => avatar.avtarMedia!)
                    //                     .first,
                    //                 imageBuilder: (context, imageProvider) =>
                    //                     Container(
                    //                   decoration: BoxDecoration(
                    //                     shape: BoxShape.circle,
                    //                     image: DecorationImage(
                    //                       image: imageProvider,
                    //                       fit: BoxFit.cover,
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 errorWidget: (context, url, error) =>
                    //                     const Icon(Icons.person,
                    //                         color: chatColor),
                    //               )
                    //             : Hive.box(userdata).get(userGender) != null &&
                    //                     Hive.box(userdata).get(userGender) ==
                    //                         "female"
                    //                 ? CachedNetworkImage(
                    //                     imageUrl: avatarController.avatarsData
                    //                         .where((avatar) =>
                    //                             avatar.avatarGender ==
                    //                                 "female" &&
                    //                             avatar.defaultAvtar == true)
                    //                         .map((avatar) => avatar.avtarMedia!)
                    //                         .first,
                    //                     imageBuilder:
                    //                         (context, imageProvider) =>
                    //                             Container(
                    //                       decoration: BoxDecoration(
                    //                         shape: BoxShape.circle,
                    //                         image: DecorationImage(
                    //                           image: imageProvider,
                    //                           fit: BoxFit.cover,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                     errorWidget: (context, url, error) =>
                    //                         const Icon(Icons.person,
                    //                             color: chatColor),
                    //                   )
                    //                 : Container(
                    //                     height: 30,
                    //                     width: 30,
                    //                     decoration: BoxDecoration(
                    //                         color: chatownColor,
                    //                         shape: BoxShape.circle),
                    //                     child: const Icon(
                    //                       Icons.person,
                    //                       size: 30,
                    //                       color: Colors.black,
                    //                     ),
                    //                   ),
                    //   )
                    ? Obx(
                        () => avatarController.avatarIndex.value != -1
                            ? CachedNetworkImage(
                                imageUrl: avatarController
                                    .avatarsData[
                                        avatarController.avatarIndex.value]
                                    .avtarMedia!,
                                // ... existing ImageBuilder ...
                              )
                            : Hive.box(userdata).get(userGender) == "male"
                                ? _getDefaultMaleAvatar()
                                : Hive.box(userdata).get(userGender) != null &&
                                        Hive.box(userdata).get(userGender) ==
                                            "female"
                                    ? _getDefaultFemaleAvatar()
                                    : Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            color: chatownColor,
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                      )
                    : Image.file(image!, fit: BoxFit.cover)),
      ),
    );
  }

  Widget pickImage() {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF),
        border: Border.all(
          width: 1,
          color: const Color(0xffEFEFEF),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 17,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose From',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  color: Color(0xff000000)),
            ),
          ),
          const SizedBox(
            height: 33,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  getImageFromCamera();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: chatownColor.withOpacity(0.16),
                      ),
                      child: Image.asset(
                        "assets/images/camera.png",
                        color: appColorBlack,
                        scale: 1.8,
                      ).paddingAll(13),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      languageController.textTranslate('Camera'),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          fontFamily: "Poppins",
                          color: Color(0xff959595)),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 40,
              ),
              GestureDetector(
                onTap: () {
                  getImageFromGallery();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: chatownColor.withOpacity(0.16),
                      ),
                      child: Image.asset(
                        "assets/images/gallery.png",
                        color: appColorBlack,
                        scale: 1.8,
                      ).paddingAll(13),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Gallery',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          fontFamily: "Poppins",
                          color: Color(0xff959595)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 33,
          ),
        ],
      ).paddingSymmetric(horizontal: 18),
    );
  }

  Widget orField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
                color: chatownColor,
                borderRadius: const BorderRadius.all(Radius.circular(5))),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        const Text(
          'OR',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              fontFamily: "Poppins",
              color: Color(0xff3A3333)),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
                color: chatownColor,
                borderRadius: const BorderRadius.all(Radius.circular(5))),
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 30);
  }

  File? image;
  final picker = ImagePicker();
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        avatarController.avatarIndex.value = -1;
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        avatarController.avatarIndex.value = -1;
      } else {
        print('No image selected.');
      }
    });
  }

  bool buttonClick = false;

  final ApiHelper apiHelper = ApiHelper();

  UserProfileModel userProfileModel = UserProfileModel();

  editApiCall() async {
    closeKeyboard();

    setState(() {
      buttonClick = true;
    });

    var uri = Uri.parse(apiHelper.userCreateProfile);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
    };
    request.headers.addAll(headers);

    if (image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('files', image!.path));
    } else if (avatarController.avatarIndex.value != -1) {
      request.fields['avatar_id'] = avatarController
          .avatarsData[avatarController.avatarIndex.value].avatarId
          .toString();
    } else if (profileImg!.isNotEmpty &&
        profileImg !=
            "https://whoxachat.com/uploads/not-found-images/profile-image.png" &&
        avatarController.avatarsData
            .where((avatar) => avatar.avtarMedia == profileImg)
            .map((avatar) => avatar.avtarMedia!)
            .isNotEmpty &&
        avatarController.avatarIndex.value == -1 &&
        image == null) {
      request.fields['avatar_id'] = avatarController.avatarsData
          .where((avatar) => avatar.avtarMedia == profileImg)
          .map((avatar) => avatar.avatarId!.toString())
          .first;
    } else {
      if (Hive.box(userdata).get(userGender) == "male") {
        request.fields['avatar_id'] = avatarController.avatarsData
            .where((avatar) =>
                avatar.avatarGender == "male" && avatar.defaultAvtar == true)
            .map((avatar) => avatar.avatarId.toString())
            .first;
      } else {
        request.fields['avatar_id'] = avatarController.avatarsData
            .where((avatar) =>
                avatar.avatarGender == "female" && avatar.defaultAvtar == true)
            .map((avatar) => avatar.avatarId.toString())
            .first;
      }
    }

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);

    if (userProfileModel.success == true) {
      await Hive.box(userdata)
          .put(userImage, userProfileModel.resData!.profileImage.toString());

      setState(() {
        buttonClick = false;
      });

      log(responseData);

      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            curve: Curves.linear,
            type: PageTransitionType.rightToLeft,
            child: TabbarScreen(currentTab: 0),
          ),
          (route) => false);

      showCustomToast(languageController.textTranslate('Success'));
    } else {
      setState(() {
        buttonClick = false;
      });
      showCustomToast("Error");
    }
  }

  Widget _getDefaultMaleAvatar() {
    final maleAvatars = avatarController.avatarsData.where((avatar) =>
        avatar.avatarGender == "male" && avatar.defaultAvtar == true);

    if (maleAvatars.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: maleAvatars.first.avtarMedia!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.person, color: chatColor),
      );
    } else {
      return Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(color: chatownColor, shape: BoxShape.circle),
        child: const Icon(
          Icons.person,
          size: 30,
          color: Colors.black,
        ),
      );
    }
  }

  Widget _getDefaultFemaleAvatar() {
    final femaleAvatars = avatarController.avatarsData.where((avatar) =>
        avatar.avatarGender == "female" && avatar.defaultAvtar == true);

    if (femaleAvatars.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: femaleAvatars.first.avtarMedia!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.person, color: chatColor),
      );
    } else {
      return Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(color: chatownColor, shape: BoxShape.circle),
        child: const Icon(
          Icons.person,
          size: 30,
          color: Colors.black,
        ),
      );
    }
  }
}
