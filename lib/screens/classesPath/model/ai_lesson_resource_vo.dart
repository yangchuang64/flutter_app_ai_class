
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';

/// 资源类型
/// PREVIEW: 课前预习，
/// REVIEW: 课后复习，
/// AI_INTERACTIVE_LESSON : ai互动课 ,
/// STUDY_REPORT:学习报告
enum LessonAttr {
  unknown, // default
  PREVIEW,
  REVIEW,
  AI_INTERACTIVE_LESSON,
  STUDY_REPORT,
}

///
/// 课前课后资源model 上ai课之前的页面的额model
///
class AiLessonResourceVO extends BaseRespData {
  int classId;
  int lessonNum;
  int lessonId;
  String beginDate;
  String endDate;
  String classLessonName;
  LessonAttr lessonAttr;
  String stuNum;
  int homeworkId;
  int previewId;
  String currentTime;
  int classLessonId;
  int resourceId;
  int teacherId;
  String teacherName;
  String resourceUrl;
  String ai_lesson_id;
  String aiLessonId;
  String aiLessonName;


  // 学习进度字段，需要进度接口查询赋值
  int finishedState;
  int finishedCount;
  int lessonCount;
  int aiId;

  AiLessonResourceVO();

  /// json
  AiLessonResourceVO.fromJson(Map<String, dynamic> json) {
    if (json is Map) {
      this.classId = (json["classId"] ?? 0) ~/ 1 as int;
      this.lessonNum = (json["lessonNum"] ?? 0) ~/ 1 as int;
      this.lessonId = (json["lessonId"] ?? 0) ~/ 1 as int;
      this.homeworkId = (json["homeworkId"] ?? 0) ~/ 1 as int;
      this.previewId = (json["previewId"] ?? 0) ~/ 1 as int;
      this.classLessonId = (json["classLessonId"] ?? 0) ~/ 1 as int;
      this.resourceId = (json["resourceId"] ?? 0) ~/ 1 as int;
      this.teacherId = (json["teacherId"] ?? 0) ~/ 1 as int;
      this.classId = (json["classId"] ?? 0) ~/ 1 as int;
      //
      this.beginDate = json["beginDate"] as String;
      this.endDate = json["endDate"] as String;
      this.classLessonName = json["classLessonName"] as String;
      this.lessonAttr = _matchLessonAttr(json["lessonAttr"]);
      this.stuNum = json["stuNum"] as String;
      this.currentTime = json["currentTime"] as String;
      this.teacherName = json["teacherName"] as String;
      this.resourceUrl = json["resourceUrl"] as String;
      this.ai_lesson_id = json["ai_lesson_id"] as String;
      this.aiLessonId = json["aiLessonId"] as String;
      this.aiLessonName = json["aiLessonName"] as String;
    }
  }

  ///
  LessonAttr _matchLessonAttr(String attr) {
    if (attr == "PREVIEW") return LessonAttr.PREVIEW;
    if (attr == "REVIEW") return LessonAttr.REVIEW;
    if (attr == "AI_INTERACTIVE_LESSON") return LessonAttr.AI_INTERACTIVE_LESSON;
    if (attr == "STUDY_REPORT") return LessonAttr.STUDY_REPORT;
    return LessonAttr.unknown;
  }

  ///
  @override
  AiLessonResourceVO translateData(dynamic data) => AiLessonResourceVO.fromJson(data);
}

///
/// 旧版ai课资源列表模型
///
class OldAiLessonResourceVO extends BaseRespData {
  int classId;
  int lessonNum;
  int lessonId;
  String beginDate;
  String endDate;
  String classLessonName;
  String lessonAttr; //IN_CLASS",//资源类型PREVIEW: 课前预习，REVIEW: 课后复习，PARENT_CLASSROOM: 家长小课堂，IN_CLASS: 课中，ATHOME，PREVIEW_AICLASS:其他资源模块课前ai，REVIEW_AICLASS:其他资源模块课后ai，
  String stuNum;
  String homeworkId;
  String previewId;
  int finish; //完成状态1已完成0未完成2无资源
  String finishDate;
  int classLessonId;
  int lessonWay; //  1直播,2 ai课堂,4 视频课
  int aiId;

  OldAiLessonResourceVO();

  /// json
  OldAiLessonResourceVO.fromJson(Map<String, dynamic> json) {
    if (json is Map) {
      this.classId = (json["classId"] ?? 0) ~/ 1 as int;
      this.lessonNum = (json["lessonNum"] ?? 0) ~/ 1 as int;
      this.lessonId = (json["lessonId"] ?? 0) ~/ 1 as int;
      this.finish = (json["finish"] ?? 0) ~/ 1 as int;
      this.lessonWay = (json["lessonWay"] ?? 0) ~/ 1 as int;
      this.aiId = (json["aiId"] ?? 0) ~/ 1 as int;
      this.classLessonId = (json["classLessonId"] ?? 0) ~/ 1 as int;
      //
      this.beginDate = json["beginDate"] as String;
      this.endDate = json["endDate"] as String;
      this.classLessonName = json["classLessonName"] as String;
      this.lessonAttr = json["lessonAttr"] as String;
      this.stuNum = json["stuNum"] as String;
      this.homeworkId = json["homeworkId"] as String;
      this.previewId = json["previewId"] as String;
      this.finishDate = json["finishDate"] as String;
      if (inProduction == false) this.originValue = json;
    }
  }

  ///
  @override
  OldAiLessonResourceVO translateData(dynamic data) => OldAiLessonResourceVO.fromJson(data);

  /// 吧旧model转新的model
  static List<AiLessonResourceVO> convertFrom(List<OldAiLessonResourceVO> list) {
    List<AiLessonResourceVO> temp = [];
    for (OldAiLessonResourceVO value in (list ?? [])) {
      AiLessonResourceVO resourceVO = AiLessonResourceVO();
      resourceVO.beginDate = value.beginDate;
      resourceVO.endDate = value.endDate;
      resourceVO.lessonId = value.lessonId;
      resourceVO.classLessonId = value.classLessonId;
      resourceVO.classId = value.classId;
      resourceVO.lessonNum = value.lessonNum;
      resourceVO.classLessonName = value.classLessonName;
      resourceVO.aiId = value.aiId;
      resourceVO.finishedState = value.finish;
//      resourceVO.resourceId = value.aiId
      temp.add(resourceVO);
    }
    return temp;
  }
}
