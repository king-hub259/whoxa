class UserProfileModel {
  UserProfileModel({this.message, this.success, this.resData});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    resData =
        json['resData'] != null ? ResData.fromJson(json['resData']) : null;
  }

  String? message;
  ResData? resData;
  bool? success;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['success'] = success;
    if (resData != null) {
      data['resData'] = resData!.toJson();
    }
    return data;
  }
}

class ResData {
  ResData(
      {this.profileImage,
      this.userId,
      this.phoneNumber,
      this.country,
      this.countryFullName,
      this.firstName,
      this.lastName,
      this.deviceToken,
      this.userName,
      this.bio,
      this.dob,
      this.countryCode,
      this.password,
      this.gender,
      this.email});

  ResData.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    phoneNumber = json['phone_number'];
    country = json['country'];
    countryFullName = json['country_full_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    deviceToken = json['device_token'];
    userName = json['user_name'];
    bio = json['bio'];
    dob = json['dob'];
    countryCode = json['country_code'];
    password = json['password'];
    gender = json['gender'];
    email = json['email_id'];
  }

  String? bio;
  String? country;
  String? countryFullName;
  String? countryCode;
  String? deviceToken;
  String? dob;
  String? firstName;
  String? gender;
  String? lastName;
  String? password;
  String? phoneNumber;
  String? profileImage;
  int? userId;
  String? userName;
  String? email;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['phone_number'] = phoneNumber;
    data['country'] = country;
    data['country_full_name'] = countryFullName;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['device_token'] = deviceToken;
    data['user_name'] = userName;
    data['bio'] = bio;
    data['dob'] = dob;
    data['country_code'] = countryCode;
    data['password'] = password;
    data['gender'] = gender;
    data['email_id'] = email;
    return data;
  }
}
