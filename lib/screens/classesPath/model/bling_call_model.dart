import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';

class PreviewReviewResourceModel extends BaseRespData {

  List<LessonResourceModel> previewLessonResources;
  List<LessonResourceModel> reviewLessonResources;

  PreviewReviewResourceModel();

  PreviewReviewResourceModel.fromJson(Map<String, dynamic> json) {
    previewLessonResources = (json["previewLessonResources"] as List)?.map((i) {
      return LessonResourceModel.fromJson(i);
    })?.toList();
    reviewLessonResources = (json["reviewLessonResources"] as List)?.map((i) {
      return LessonResourceModel.fromJson(i);
    })?.toList();
  }

  @override
  BaseRespData translateData(dynamic data) {
    return PreviewReviewResourceModel.fromJson(data);
  }
}

class LessonResourceModel extends BaseRespData {
  int lessonId;
  String lessonAttr;
  String resourceName;
  String levelName;
  int resourceType;
  int levelCode;
  int seq;

  LessonResourceContentModel resourceContent;

  LessonResourceModel();

  LessonResourceModel.fromJson(Map<String, dynamic> json) {
    lessonAttr = json['lessonAttr'];
    resourceName = json['resourceName'];
    levelName = json['levelName'];
    lessonId = (json["lessonId"] ?? 0) ~/ 1 as int;
    resourceType = (json["resourceType"] ?? 0) ~/ 1 as int;
    levelCode = (json["levelCode"] ?? 0) ~/ 1 as int;
    seq = (json["seq"] ?? 0) ~/ 1 as int;
    resourceContent = LessonResourceContentModel.fromJson(json["resourceContent"]);
  }

  @override
  BaseRespData translateData(dynamic data) {
    return LessonResourceModel.fromJson(data);
  }
}


class LessonResourceContentModel extends BaseRespData {
  int homeworkId;
  String contentUrl;
  String teacherName;
  String teacherImage;
  String blingCallText;

  LessonResourceContentModel();

  LessonResourceContentModel.fromJson(Map<String, dynamic> json) {
    contentUrl = json['contentUrl'];
    teacherName = json['teacherName'];
    teacherImage = json['teacherImage'];
    blingCallText = json['blingCallText'];
    homeworkId = (json["homeworkId"] ?? 0) ~/ 1 as int;
  }

  @override
  BaseRespData translateData(dynamic data) {
    return LessonResourceContentModel.fromJson(data);
  }
}
