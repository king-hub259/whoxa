// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/add_member_group_model.dart';
import 'package:whoxachat/Models/group_create_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';

final ApiHelper apiHelper = ApiHelper();

class GroupCreateController extends GetxController {
  RxBool isCreate = false.obs;

  Rx<GroupCreateModel?> createModel = GroupCreateModel().obs;

  RxBool isMember = false.obs;
  Rx<AddMemberGroupModel?> model = AddMemberGroupModel().obs;

  groupCreateApi(String gpname, file, String conversationId,
      List<SelectedContact> contactData) async {
    isCreate(true);
    try {
      var uri = Uri.parse(apiHelper.createGroup);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['group_name'] = gpname;

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('files', file));
      }

      print("create-group ${request.fields}");
      print("create-group ${request.files}");
      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();

      var userData = json.decode(responseData);

      createModel.value = GroupCreateModel.fromJson(userData);

      print("create-group $responseData");

      if (createModel.value!.success == true) {
        addToGroupMember(createModel.value!.conversationId.toString(),
            contactData.map((e) => e.userId.toString()).toList());
        showCustomToast(createModel.value!.message!);
        isCreate(false);
      } else {
        isCreate(false);
        showCustomToast(createModel.value!.message!);
      }
    } catch (e) {
      isCreate(false);
      showCustomToast(e.toString());
    } finally {
      isCreate(false);
    }
  }

  addToGroupMember(String conversationID, contactList) async {
    isMember(true);
    try {
      var uri = Uri.parse(apiHelper.addMemberToGroup);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID;
      request.fields['multiple_user_id'] = contactList
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "")
          .replaceAll(" ", "");

      print("add members ${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();

      var userData = json.decode(responseData);

      model.value = AddMemberGroupModel.fromJson(userData);

      if (model.value!.success == true) {
        isMember(false);
        Get.offAll(() => TabbarScreen(currentTab: 0));
      } else {
        isMember(false);
      }
    } catch (e) {
      isMember(false);
      showCustomToast(e.toString());
    } finally {
      isMember(false);
    }
  }

  groupCreateUpate(String gpname, file, String conversationId) async {
    isCreate(true);
    try {
      var uri = Uri.parse(apiHelper.createGroup);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['group_name'] = gpname;
      request.fields['conversation_id'] = conversationId;
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('files', file));
      }
      print(request.fields);
      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();

      var userData = json.decode(responseData);

      createModel.value = GroupCreateModel.fromJson(userData);

      if (createModel.value!.success == true) {
        isCreate(false);
        showCustomToast(createModel.value!.message!);
      } else {
        isCreate(false);
        showCustomToast(createModel.value!.message!);
      }
    } catch (e) {
      isCreate(false);
      showCustomToast(e.toString());
    } finally {
      isCreate(false);
    }
  }
}
