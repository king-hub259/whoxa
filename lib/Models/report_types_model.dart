class ReportTypesModel {
  bool? success;
  String? message;
  List<ReportType>? reportType;

  ReportTypesModel({this.success, this.message, this.reportType});

  ReportTypesModel.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    message = json["message"];
    reportType = json["reportType"] == null
        ? null
        : (json["reportType"] as List)
            .map((e) => ReportType.fromJson(e))
            .toList();
  }

  static List<ReportTypesModel> fromList(List<Map<String, dynamic>> list) {
    return list.map(ReportTypesModel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["success"] = success;
    data["message"] = message;
    if (reportType != null) {
      data["reportType"] = reportType?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class ReportType {
  int? reportId;
  String? reportTitle;
  String? reportDetails;
  String? reportFor;
  String? createdAt;
  String? updatedAt;

  ReportType(
      {this.reportId,
      this.reportTitle,
      this.reportDetails,
      this.reportFor,
      this.createdAt,
      this.updatedAt});

  ReportType.fromJson(Map<String, dynamic> json) {
    reportId = json["report_id"];
    reportTitle = json["report_title"];
    reportDetails = json["report_details"];
    reportFor = json["report_for"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
  }

  static List<ReportType> fromList(List<Map<String, dynamic>> list) {
    return list.map(ReportType.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["report_id"] = reportId;
    data["report_title"] = reportTitle;
    data["report_details"] = reportDetails;
    data["report_for"] = reportFor;
    data["createdAt"] = createdAt;
    data["updatedAt"] = updatedAt;
    return data;
  }
}
