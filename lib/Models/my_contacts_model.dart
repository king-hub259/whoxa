class MyContactModel {
  bool? success;
  String? message;
  List<MyContactList>? myContactList;
  Pagination? pagination;

  MyContactModel(
      {this.success, this.message, this.myContactList, this.pagination});

  MyContactModel.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    message = json["message"];
    myContactList = json["myContactList"] == null
        ? null
        : (json["myContactList"] as List)
            .map((e) => MyContactList.fromJson(e))
            .toList();
    pagination = json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["success"] = success;
    data["message"] = message;
    if (myContactList != null) {
      data["myContactList"] = myContactList?.map((e) => e.toJson()).toList();
    }
    if (pagination != null) {
      data["pagination"] = pagination?.toJson();
    }
    return data;
  }
}

class Pagination {
  int? count;
  int? currentPage;
  int? totalPages;

  Pagination({this.count, this.currentPage, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    count = json["count"];
    currentPage = json["currentPage"];
    totalPages = json["totalPages"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["count"] = count;
    data["currentPage"] = currentPage;
    data["totalPages"] = totalPages;
    return data;
  }
}

class MyContactList {
  int? contactId;
  String? phoneNumber;
  String? fullName;
  UserDetails? userDetails;

  MyContactList(
      {this.contactId, this.phoneNumber, this.fullName, this.userDetails});

  MyContactList.fromJson(Map<String, dynamic> json) {
    contactId = json["contact_id"];
    phoneNumber = json["phone_number"];
    fullName = json["full_name"];
    userDetails = json["userDetails"] == null
        ? null
        : UserDetails.fromJson(json["userDetails"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["contact_id"] = contactId;
    data["phone_number"] = phoneNumber;
    data["full_name"] = fullName;
    if (userDetails != null) {
      data["userDetails"] = userDetails?.toJson();
    }
    return data;
  }
}

class UserDetails {
  String? profileImage;
  int? userId;
  String? userName;

  UserDetails({this.profileImage, this.userId, this.userName});

  UserDetails.fromJson(Map<String, dynamic> json) {
    profileImage = json["profile_image"];
    userId = json["user_id"];
    userName = json["user_name"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["profile_image"] = profileImage;
    data["user_id"] = userId;
    data["user_name"] = userName;
    return data;
  }
}
