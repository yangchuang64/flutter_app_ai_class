import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';

class PathBeforeModel {
  dotRecord(
    String stuNum,
    String parentMobile,
    int classId,
    int classLessonId,
    int studyStatus,
    int enterTime,
    int quitTime,
    int resourceId,
    int resourceType,
    int gameLevel,
    bool isContinue,
    int studyTime,
  ) async {
    // print('ai_log studyTime:${studyTime}');
    NetRequest.post(
      url: ApiConfigs.aiDotRecord,
      param: {
        "stuNum": stuNum,
        'parentMobile': parentMobile,
        'classId': classId,
        'classLessonId': classLessonId,
        'studyStatus': studyStatus,
        'enterTime': enterTime,
        'quitTime': quitTime,
        'resourceId': resourceId,
        'resourceType': resourceType,
        'gameLevel': gameLevel,
        'continueFlag': isContinue ? 1 : 0,
        'studyTime': num.parse((studyTime / (1000 * 60)).toStringAsFixed(2)),
      },
    );
  }
}
