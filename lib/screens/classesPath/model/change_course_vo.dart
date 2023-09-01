import 'package:flutter_app_ai_math/screens/classesPath/model/student_class_vo.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';

///
/// 切换课程(切换语数外课程等)-模型
class ChangeCourseVO extends BaseRespData {
  List<AiStudentClassVO> chinese;
  List<AiStudentClassVO> math;
  List<AiStudentClassVO> english;

  ChangeCourseVO();

  /// json
  ChangeCourseVO.fromJson(Map<String, dynamic> json) {
    if (json is Map) {
      this.chinese = (json["40"] as List)?.map((i) {
        return AiStudentClassVO.fromJson(i);
      })?.toList();
      this.math = (json["50"] as List)?.map((i) {
        return AiStudentClassVO.fromJson(i);
      })?.toList();
      this.english = (json["10"] as List)?.map((i) {
        return AiStudentClassVO.fromJson(i);
      })?.toList();
    }
  }

  @override
  ChangeCourseVO translateData(dynamic data) => ChangeCourseVO.fromJson(data);
}
