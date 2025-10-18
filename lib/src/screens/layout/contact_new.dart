// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison, prefer_is_empty, must_be_immutable, deprecated_member_use, unused_field, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/add_contact_controller.dart';
import 'package:whoxachat/controller/get_contact_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/model/userchatlist_model/userchatlist_model.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/screens/Group/add_gp_member.dart';
import 'package:whoxachat/src/screens/chat/create_group.dart';
import 'package:whoxachat/src/screens/chat/shareable/common_permission_dialog.dart';
import 'package:whoxachat/src/screens/chat/single_chat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';

class FlutterContactsExample extends StatefulWidget {
  bool isValue;
  FlutterContactsExample({super.key, required this.isValue});

  @override
  _FlutterContactsExampleState createState() => _FlutterContactsExampleState();
}

class _FlutterContactsExampleState extends State<FlutterContactsExample> {
  List<Contact>? _contacts;

  TextEditingController controller = TextEditingController();
  String searchText = '';
  GetAllDeviceContact getAllDeviceContact = Get.find();
  AddContactController addContactController = Get.find();
  ChatListController chatListController = Get.find();
  List<Contact> filteredContacts = [];
  bool _isPermissionGranted = false;

  @override
  void initState() {
    _checkContactPermission();

    apis();
    log(Hive.box(userdata).get(userMobile), name: "USER-MOBILE");
    super.initState();
  }

  Future<void> _checkContactPermission() async {
    var permission = await Permission.contacts.request();

    if (permission.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
    } else if (permission.isDenied) {
      // If denied, show a message or retry
      print("Permission denied. Ask user to grant manually.");
    } else if (permission.isPermanentlyDenied) {
      // Open app settings if permanently denied
      // openAppSettings();
      PermissionUtil.showPermissionSettingsDialog(
          context,
          "Location", // or "Location", "Microphone", etc.
          languageController.textTranslate,
          chatownColor,
          secondaryColor);
    }
  }

  Future<void> apis() async {
    log("MY_DEVICE_CONTACS: ${addContactController.mobileContacts}");

    chatListController.forChatList();
  }

  void filterContacts(String query) {
    if (_contacts != null) {
      setState(() {
        filteredContacts = _contacts!
            .where((contact) =>
                contact.displayName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  bool isChat = false;
  String getUserID(String mobileNum) {
    for (int i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (chatListController.userChatListModel.value!.chatList![i].isGroup ==
          false) {
        if (mobileNum ==
            chatListController
                .userChatListModel.value!.chatList![i].phoneNumber) {
          return chatListController
              .userChatListModel.value!.chatList![i].conversationId
              .toString();
        }
        isChat = true;
      }
    }
    return '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        backgroundColor: appColorWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Image.network(
          languageController.appSettingsData[0].appLogo!,
          height: 45,
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: appColorWhite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: commonSearchField(
                        context: context,
                        controller: controller,
                        onChanged: (value) {
                          setState(() {
                            searchText = value.toLowerCase().trim();
                          });
                        },
                        hintText: languageController
                            .textTranslate('Search name or number'),
                      ),
                      //     Container(
                      //   height: 50,
                      //   width: MediaQuery.of(context).size.width * 0.9,
                      //   decoration: BoxDecoration(
                      //       color: const Color.fromRGBO(238, 238, 238, 1),
                      //       borderRadius: BorderRadius.circular(10)),
                      //   child: TextField(
                      //     controller: controller,
                      //     onChanged: (value) {
                      //       setState(() {
                      //         searchText = value.toLowerCase().trim();
                      //       });
                      //     },
                      //     decoration: InputDecoration(
                      //       prefixIcon: const Padding(
                      //         padding: EdgeInsets.all(17),
                      //         child: Image(
                      //           image: AssetImage('assets/icons/search.png'),
                      //         ),
                      //       ),
                      //       hintText: languageController
                      //           .textTranslate('Search name or number'),
                      //       hintStyle: const TextStyle(
                      //           fontSize: 12, color: Colors.grey),
                      //       filled: true,
                      //       fillColor: Colors.transparent,
                      //       border: const OutlineInputBorder(
                      //         borderSide: BorderSide.none,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () {
                  Get.to(() => AddMembersinGroup1());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Row(
                    children: [
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Center(
                              child: Image.asset(
                                "assets/images/group1.png",
                                color: chatownColor,
                              ),
                            )),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        languageController.textTranslate('New Group'),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                thickness: 1.5,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: RefreshIndicator(
                  color: chatownColor,
                  onRefresh: () {
                    var contactJson =
                        json.encode(addContactController.mobileContacts);
                    return getAllDeviceContact.getAllContactApi(
                        contact: contactJson);
                  },
                  child: Obx(
                    () => addContactController
                                    .isGetContectsFromDeviceLoading.value ==
                                true &&
                            (getAllDeviceContact
                                        .myContactsData.value.myContactList ==
                                    null ||
                                addContactController.allcontacts.isEmpty)
                        ? loader(context)
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                controller.text.trim().isEmpty
                                    ? contactDesign()
                                    // : const SizedBox.shrink(),
                                    : SizedBox(
                                        height: 100,
                                        child: Center(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(languageController.textTranslate(
                                                'You don\'t have any contact using this app.')),
                                          ],
                                        )),
                                      ),
                                getAllDeviceContact.myContactsData.value
                                                .myContactList !=
                                            null &&
                                        getAllDeviceContact.myContactsData.value
                                            .myContactList!.isNotEmpty
                                    ? contactsWidget()
                                    : const SizedBox.shrink(),
                                controller.text.trim().isEmpty
                                    ? const SizedBox(height: 5)
                                    : const SizedBox.shrink(),
                                controller.text.trim().isEmpty
                                    ? Divider(
                                        thickness: 1.5,
                                        color: Colors.grey.shade200,
                                      )
                                    : const SizedBox.shrink(),
                                controller.text.trim().isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 18, top: 10),
                                        child: Text(
                                          '${languageController.textTranslate('Invite Friend to Chatweb')} ',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                controller.text.trim().isEmpty
                                    ? const SizedBox(height: 5)
                                    : const SizedBox.shrink(),
                                inviteFriend(searchText)
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget contactsWidget() {
    return getAllDeviceContact.isGetMYContectLoading.value == true
        ? loader(context)
        : getAllDeviceContact.myContactsData.value.myContactList!.isNotEmpty
            ? ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: getAllDeviceContact
                    .myContactsData.value.myContactList!
                    .where((contact) => contact.fullName!
                        .toLowerCase()
                        .contains(searchText.toLowerCase()))
                    .length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  var filteredContacts = getAllDeviceContact
                      .myContactsData.value.myContactList!
                      .where((contact) => contact.fullName!
                          .toLowerCase()
                          .contains(searchText.toLowerCase()))
                      .toList();

                  if (filteredContacts.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  var contact = filteredContacts[index];
                  return getAllDeviceContact.myContactsData.value.myContactList!
                          .any((element) =>
                              element.phoneNumber.toString() ==
                              Hive.box(userdata).get(userMobile))
                      ? Hive.box(userdata).get(userMobile) ==
                              contact.phoneNumber.toString()
                          ? const SizedBox.shrink()
                          : Divider(
                              color: Colors.grey.shade300,
                            )
                      : index !=
                              getAllDeviceContact.myContactsData.value
                                      .myContactList!.length -
                                  1
                          ? Divider(
                              color: Colors.grey.shade300,
                            )
                          : const SizedBox.shrink();
                },
                itemBuilder: (BuildContext context, int index) {
                  var filteredContacts = getAllDeviceContact
                      .myContactsData.value.myContactList!
                      .where((contact) => contact.fullName!
                          .toLowerCase()
                          .contains(searchText.toLowerCase()))
                      .toList();

                  if (filteredContacts.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  var contact = filteredContacts[index];
                  return Hive.box(userdata).get(userMobile) ==
                          contact.phoneNumber.toString()
                      ? const SizedBox.shrink()
                      : Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                if (chatListController.userChatListModel.value!
                                    .chatList!.isEmpty) {
                                  Get.to(() => SingleChatMsg(
                                        conversationID: '',
                                        username: contact.fullName!,
                                        userPic:
                                            contact.userDetails!.profileImage,
                                        mobileNum:
                                            contact.phoneNumber.toString(),
                                        index: 0,
                                        userID: contact.userDetails!.userId
                                            .toString(),
                                      ));
                                } else {
                                  if (chatListController
                                      .userChatListModel.value!.chatList!
                                      .where((element) =>
                                          contact.userDetails!.userId
                                              .toString() ==
                                          element.userId!.toString())
                                      .isNotEmpty) {
                                    ChatList data = chatListController
                                        .userChatListModel.value!.chatList!
                                        .where((element) =>
                                            contact.userDetails!.userId
                                                .toString() ==
                                            element.userId!.toString())
                                        .first;
                                    Get.to(() => SingleChatMsg(
                                          conversationID:
                                              data.conversationId.toString(),
                                          username: contact.fullName!,
                                          userPic:
                                              contact.userDetails!.profileImage,
                                          mobileNum:
                                              contact.phoneNumber.toString(),
                                          index: 0,
                                          isBlock: data.isBlock,
                                          userID: data.userId.toString(),
                                        ));
                                  } else {
                                    Get.to(
                                      () => SingleChatMsg(
                                        conversationID: '',
                                        username: contact.fullName!,
                                        userPic:
                                            contact.userDetails!.profileImage,
                                        mobileNum:
                                            contact.phoneNumber.toString(),
                                        index: 0,
                                        userID: contact.userDetails!.userId!
                                            .toString(),
                                      ),
                                    );
                                  }
                                }
                              },
                              leading: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CustomCachedNetworkImage(
                                        imageUrl:
                                            contact.userDetails!.profileImage!,
                                        placeholderColor: chatownColor,
                                        errorWidgeticon:
                                            const Icon(Icons.person))),
                              ),
                              title: Text(
                                contact.fullName!,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Container(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  contact.phoneNumber.toString(),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color.fromRGBO(73, 73, 73, 1)),
                                ),
                              ),
                              trailing: Image.asset("assets/images/Chat1.png",
                                  height: 10),
                            ),
                          ],
                        );
                },
              )
            : SizedBox(
                height: 100,
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(languageController.textTranslate(
                        'You do not have any contact in chatweb!')),
                  ],
                )),
              );
  }

  bool isMatchinginvite(String userNumber) {
    for (int i = 0; i < getAllDeviceContact.getList.length; i++) {
      List<String> numbers = userNumber.split(',');
      for (String listNumber in numbers) {
        if (listNumber == getAllDeviceContact.getList[i].phoneNumber) {
          return false;
        }
      }
    }
    return true;
  }

  List<Contact> getFilteredContacts(String searchText) {
    List<Contact> filteredContacts = [];
    for (int i = 0; i < addContactController.allcontacts.length; i++) {
      Contact contact = addContactController.allcontacts[i];
      if (isMatchinginvite(
              getMobile(contact.phones.map((e) => e.number).toString())) &&
          (contact.displayName.toLowerCase().contains(searchText))) {
        filteredContacts.add(contact);
      }
    }
    return filteredContacts;
  }

  Widget inviteFriend(String searchText) {
    List<Contact> filteredContacts = getFilteredContacts(searchText);
    return _isPermissionGranted == false
        ? Column(
            children: [
              sizeBoxHeight(20),
              Image.asset(
                "assets/images/no_contact.png",
                height: getProportionateScreenHeight(201),
                width: getProportionateScreenHeight(134),
              ),
              sizeBoxHeight(15),
              const Text(
                "You Don’t have permission to access contacts, go to settings and change the permission",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: appColorBlack,
                ),
              ).paddingSymmetric(horizontal: 50),
              sizeBoxHeight(15),
            ],
          )
        : addContactController.isGetContectsFromDeviceLoading.value == true &&
                addContactController.allcontacts.isEmpty
            ? loader(context)
            : addContactController.allcontacts.isEmpty
                ? Column(
                    children: [
                      sizeBoxHeight(20),
                      Image.asset(
                        "assets/images/no_contact.png",
                        height: getProportionateScreenHeight(201),
                        width: getProportionateScreenHeight(134),
                      ),
                      sizeBoxHeight(15),
                      const Text(
                        "You don’t have any Contacts on your device.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                          color: appColorBlack,
                        ),
                      ).paddingSymmetric(horizontal: 50),
                      sizeBoxHeight(15),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: filteredContacts.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      var contact = filteredContacts[index];

                      return Column(
                        children: <Widget>[
                          getMobile(Hive.box(userdata).get(userMobile)) ==
                                  getMobile(contact.phones
                                      .map((e) => e.number)
                                      .toString())
                              ? const SizedBox.shrink()
                              : ListTile(
                                  onTap: () {
                                    inviteMe(contact.phones
                                        .map((e) => e.number)
                                        .toString());
                                  },
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            colors: [
                                              blackColor,
                                              black1Color,
                                            ],
                                            stops: const [
                                              1.0,
                                              3.0
                                            ],
                                            begin: FractionalOffset.topLeft,
                                            end: FractionalOffset.bottomRight,
                                            tileMode: TileMode.repeated)),
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Center(
                                          child: Text(
                                            contact.displayName != null
                                                ? contact.displayName[0]
                                                : "?",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontFamily: "MontserratBold",
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ),
                                  title: Text(
                                    contact.displayName,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Container(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        getMobile(contact.phones
                                            .map((e) => e.number)
                                            .toString()),
                                        maxLines: 1,
                                        style: const TextStyle(
                                            color:
                                                Color.fromRGBO(73, 73, 73, 1)),
                                      )),
                                  trailing: Text(
                                    languageController.textTranslate('Invite'),
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: chatownColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                          if (index != filteredContacts.length - 1)
                            Divider(
                              color: Colors.grey.shade300,
                            )
                        ],
                      );
                    },
                  );
  }

  inviteMe(phone) async {
    String uri =
        'sms:$phone?body=${languageController.appSettingsData[0].tellAFriendLink}';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      String uri =
          'sms:$phone?body=${languageController.appSettingsData[0].tellAFriendLink}';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }
  // inviteMe(phone) async {
  //   String uri =
  //       'sms:$phone?body=${"‎Hey there! Join me on our Whoxa app!\nChat with friends, share photos & videos instantly.\nDownload now.\nLet's stay connected!"}';
  //   if (await canLaunch(uri)) {
  //     await launch(uri);
  //   } else {
  //     String uri =
  //         'sms:$phone?body=${"‎Hey there! Join me on our Whoxa app!\nChat with friends, share photos & videos instantly.\nDownload now.\nLet's stay connected!"}';
  //     if (await canLaunch(uri)) {
  //       await launch(uri);
  //     } else {
  //       throw 'Could not launch $uri';
  //     }
  //   }
  // }

  Widget contactDesign() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 10),
          child: Text(
            languageController.textTranslate('Contact on Chatweb'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future images() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, kk) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            title: Center(
              child: Text(
                languageController.textTranslate('Group Info'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: chatColor,
                ),
              ),
            ),
            content: const SizedBox(height: 243, child: create_group()),
          );
        });
      },
    );
  }
}
