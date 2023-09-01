
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';

class StudyReportModel extends BaseRespData {
  String stuNum;
  int resourceId; // 资源ID（课前课后)
  String uuid;
  String textInfo; //文字题目
  String aiModuleCode; // ai课模块编码
  String myanswer; // 答案, 课中所操作的 单词句子, 配音文件地址等
  int successTime; // 答对用时
  int contentId; // 内容id
  int grade; // 评分
  int classLessonId; // 班级课时id
  int resourceType; // 资源类型：1课前；2课后；3课中；4ai；5其他模块课后a
  String createDate; // 创建时间
  int gameLevel; // 关卡类型

  StudyReportModel({this.stuNum, this.resourceId, this.uuid, this.textInfo, this.aiModuleCode, this.myanswer, this.successTime, this.contentId, this.grade, this.classLessonId, this.resourceType, this.createDate, this.gameLevel});

  StudyReportModel.fromJson(Map<String, dynamic> json) {
    stuNum = json['stuNum'];
    resourceId = json['resourceId'];
    uuid = json['uuid'];
    textInfo = json['textInfo'];
    aiModuleCode = json['aiModuleCode'];
    myanswer = json['myanswer'];
    createDate = json['createDate'];
    successTime = (json["successTime"] ?? 0) ~/ 1 as int;
    contentId = (json["contentId"] ?? 0) ~/ 1 as int;
    grade = (json["grade"] ?? 0) ~/ 1 as int;
    classLessonId = (json["classLessonId"] ?? 0) ~/ 1 as int;
    resourceType = (json["resourceType"] ?? 0) ~/ 1 as int;
    gameLevel = (json["gameLevel"] ?? 0) ~/ 1 as int;
  }

  @override
  BaseRespData translateData(dynamic data) {
    return StudyReportModel.fromJson(data);
  }
}
