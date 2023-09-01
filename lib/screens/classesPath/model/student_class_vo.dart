
import 'package:flutterblingaiplugin/screen/uitils/date_util.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';

///
/// 路径页面，课程信息的model
///
class AiStudentClassVO extends BaseRespData {
  int classId;
  String className;
  String classEnglishName;
  int courseType;
  String courseTypeName;
  int level;
  String levelName;
  int term; //春:10 暑 : 20 秋 :30 寒 :40
  String termName;
  String stuNum;
  String classStartDate;
  String classEndDate;
  int classInfoId;
  String currentTime;
  List<AiStudentLessonVO> studentLessonVOList;
  int classStyle; // 上课方式1EEO,2展示互动3百家云4roombox 5:ai
  int givedLessonNum;
  int givedNode;
  int year;
  int channelCode;
  int classCourseId;
  int state;
  String distribution;
  String distributionName;
  String courseName;
  int classWay;
  int changeState;
  int mainStatus;
  int subjectCode;
  String subjectName;
  String coveUrl;

  // 一下三个扩展字段，需要单独接口查询
  int finishedState;
  int finishedCount;
  int lessonCount;

  AiStudentClassVO();

  AiStudentClassVO.copy(AiStudentClassVO origin) {
    this.classId = origin.classId;
    this.courseType = origin.courseType;
    this.level = origin.level;
    this.term = origin.term;
    this.classInfoId = origin.classInfoId;
    this.lessonCount = origin.lessonCount;
    this.classStyle = origin.classStyle;
    this.givedLessonNum = origin.givedLessonNum;
    this.givedNode = origin.givedNode;
    this.year = origin.year;
    this.channelCode = origin.channelCode;
    this.className = origin.className;
    this.classEnglishName = origin.classEnglishName;
    this.courseTypeName = origin.courseTypeName;
    this.levelName = origin.levelName;
    this.termName = origin.termName;
    this.stuNum = origin.stuNum;
    this.classStartDate = origin.classStartDate;
    this.classEndDate = origin.classEndDate;
    this.currentTime = origin.currentTime;
    this.studentLessonVOList = origin.studentLessonVOList;
    this.classCourseId = origin.classCourseId;
    this.state = origin.state;
    this.classWay = origin.classWay;
    this.changeState = origin.changeState;
    this.mainStatus = origin.mainStatus;
    this.subjectCode = origin.subjectCode;
    this.distribution = origin.distribution;
    this.distributionName = origin.distributionName;
    this.subjectName = origin.subjectName;
    this.courseName = origin.courseName;
    this.coveUrl = origin.coveUrl;
    this.finishedState = origin.finishedState;
    this.finishedCount = origin.finishedCount;
    this.lessonCount = origin.lessonCount;
  }

  AiStudentClassVO.fromJson(Map<String, dynamic> json) {
    if (json is Map) {
      this.classId = (json["classId"] ?? 0) ~/ 1;
      this.courseType = (json["courseType"] ?? 0) ~/ 1;
      this.level = (json["level"] ?? 0) ~/ 1;
      this.term = (json["term"] ?? 0) ~/ 1;
      this.classInfoId = (json["classInfoId"] ?? 0) ~/ 1;
      this.lessonCount = (json["lessonCount"] ?? 0) ~/ 1;
      this.classStyle = (json["classStyle"] ?? 0) ~/ 1;
      this.givedLessonNum = (json["givedLessonNum"] ?? 0) ~/ 1;
      this.givedNode = (json["givedNode"] ?? 0) ~/ 1;
      this.year = (json["year"] ?? 0) ~/ 1;
      this.channelCode = (json["channelCode"] ?? 0) ~/ 1;
      //
      this.className = json["className"] as String;
      this.classEnglishName = json["classEnglishName"] as String;
      this.courseTypeName = json["courseTypeName"] as String;
      this.levelName = json["levelName"] as String;
      this.termName = json["termName"] as String;
      this.stuNum = json["stuNum"] as String;
      this.classStartDate = json["classStartDate"] as String;
      this.classEndDate = json["classEndDate"] as String;
      this.currentTime = json["currentTime"] as String;
      this.className = json["className"] as String;
      this.className = json["className"] as String;
      //
      this.studentLessonVOList = (json["studentLessonVOList"] as List)?.map((i) {
        return AiStudentLessonVO.fromJson(i);
      })?.toList();
      //
      this.classCourseId = (json["classCourseId"] ?? 0) ~/ 1 as int;
      this.state = (json["state"] ?? 0) ~/ 1 as int;
      this.classWay = (json["classWay"] ?? 0) ~/ 1 as int;
      this.changeState = (json["changeState"] ?? 0) ~/ 1 as int;
      this.mainStatus = (json["mainStatus"] ?? 0) ~/ 1 as int;
      this.subjectCode = (json["subjectCode"] ?? 0) ~/ 1 as int;
      this.distribution = json["distribution"] as String;
      this.distributionName = json["distributionName"] as String;
      this.subjectName = json["subjectName"] as String;
      this.courseName = json["courseName"] as String;
      this.coveUrl = json["coveUrl"] as String;
    }
  }

  @override
  AiStudentClassVO translateData(dynamic data) {
    return AiStudentClassVO.fromJson(data);
  }
}

class AiStudentLessonVO extends BaseRespData {
  int classId;
  int classLessonNum;
  String classLessonName;
  int score;
  String beginDate;
  String endDate;
  String currentTime;
  int classLessonId;
  int lessonId;
  int resourceState; //0 没有资源 1 有资源
  String lessonCoveUrl;
  int award;
  int isTestCourse;
  int cramStatus;
  int stuState; //10未开课 20已结课 21AI课时已学完, 30老师缺勤40学生缺勤50课程异常60上课中31老师取消41学生取消(48小时内)42学生取消(48小时外)
  int lessonType; // 1：比邻课时，2：新东方AI课时

  // 未到beginData是锁状态
  bool isLocked = false;

  AiStudentLessonVO();

  AiStudentLessonVO.fromJson(Map<String, dynamic> json) {
    if (json is Map) {
      this.lessonType = (json["lessonType"] ?? 0) ~/ 1;
      this.classId = (json["classId"] ?? 0) ~/ 1;
      this.classLessonNum = (json["classLessonNum"] ?? 0) ~/ 1;
      this.score = (json["score"] ?? 0) ~/ 1;
      this.classLessonId = (json["classLessonId"] ?? 0) ~/ 1;
      this.lessonId = (json["lessonId"] ?? 0) ~/ 1;
      this.resourceState = (json["resourceState"] ?? 0) ~/ 1;
      this.award = (json["award"] ?? 0) ~/ 1;
      this.isTestCourse = (json["isTestCourse"] ?? 0) ~/ 1;
      this.cramStatus = (json["cramStatus"] ?? 0) ~/ 1;
      this.stuState = (json["stuState"] ?? 0) ~/ 1;
      //
      this.classLessonName = json["classLessonName"] as String;
      this.beginDate = json["beginDate"] as String;
      this.endDate = json["endDate"] as String;
      this.currentTime = json["currentTime"] as String;
      this.lessonCoveUrl = json["lessonCoveUrl"] as String;
      //
      this.isLocked = _checkIsLocked();
    }
  }

  @override
  AiStudentLessonVO translateData(dynamic data) => AiStudentLessonVO.fromJson(data);

  bool _checkIsLocked() {
    if (this.beginDate == null) return false;
    DateTime current = this.currentTime == null ? DateTime.now() : DateUtil.getDateTime(this.currentTime);
    DateTime beginDate = DateUtil.getDateTime(this.beginDate);
    return current.isBefore(beginDate);
  }
}
