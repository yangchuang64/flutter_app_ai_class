import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/student_class_vo.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/date_util.dart';
import 'package:flutterblingaiplugin/screen/uitils/log.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:provider/provider.dart';
import 'package:push/bling_push.dart';

class PathViewModel {
  updatePush(String phone, String name) async {
    String token = await BlingPush.getDeviceToken();
    int counter = 0;
    while (token == null && counter < 7) {
      token = await BlingPush.getDeviceToken();
      await Future.delayed(Duration(seconds: 1));
      counter++;
    }
    printLog('ai_log', 'token:$token');
    if (token == null) {
      UiUtil.showToast("无法获取设备推送信息");
      return;
    }
    NetRequest.post(
      url: ApiConfigs.updatePushInfo,
      param: {
        "parentPhone": phone,
        'name': name,
        'mobileType': Platform.isAndroid ? 1 : 2,
        'mobileToken': token,
      },
    );
  }

  /// 获取课程本地json数据
  Future<BaseResp<AiStudentClassVO>> getPathLessonsData() async {
    BaseResp<AiStudentClassVO> resp = await NetRequest.get<AiStudentClassVO>(
      url: ApiConfigs.defaultAiClass,
      dateTypeInstance: AiStudentClassVO(),
//      jsonInAsset: "lesson.json",
      param: {"stuNum": LoginUserInfo.getInstance(null).selectedStudent?.stuNum},
    );
    if (resp?.result == true && (resp.data is AiStudentClassVO)) {
      PathViewModel.checkLessonsLockState(resp.data);
    }
    return resp;
  }

  /// 课程路径页面
  /// 检测课程加锁状态，
  /// 给新获取的数据修改锁定状态
  static void checkLessonsLockState(AiStudentClassVO aiStudentClassVO) {
    List<AiStudentLessonVO> lessons = aiStudentClassVO?.studentLessonVOList;
    lessons?.forEach((i) {
      bool noBeginDate = i.beginDate == null || i.beginDate?.isEmpty == true;
      bool hasEndClass = i.stuState == 21;
      bool hasEndLesson = i.stuState == 20;
      if (noBeginDate == true && !hasEndClass && !hasEndLesson) i.isLocked = true;
      if (noBeginDate == false && (hasEndClass || hasEndLesson)) i.isLocked = false;
    });
    for (int i = 0; i < lessons.length; i++) {
      AiStudentLessonVO value = lessons[i];
      if (value.beginDate == null || value.beginDate?.isEmpty == true) {
        if (value.isLocked == true) {
          try {
            bool lastComplete = lessons[i - 1].stuState == 21 || lessons[i - 1].stuState == 20;
            if (lastComplete == true) value.isLocked = false;
//          break;
          } catch (_) {}
        }
      }
    }
    lessons?.first?.isLocked = false;
  }

  /// 课程路径页面
  /// 解锁下一关
  /// [classLessonId] 当前学完的id
  /// *** 解锁下一关一定要保正当前关卡的学习记录提交成功 ***
  static bool unlockNextLesson(BuildContext context, int classLessonId) {
    if (context == null) return false;
    ValueNotifier valueNotifier = Provider.of<ValueNotifier<AiStudentClassVO>>(context);
    AiStudentClassVO currentClassVo = valueNotifier?.value;
    if (currentClassVo == null) return false;
    List<AiStudentLessonVO> lessons = currentClassVo.studentLessonVOList;
    for (AiStudentLessonVO lesson in lessons) {
      if (lesson.classLessonId == classLessonId) lesson.stuState = 21;
      if (lesson.isLocked == true) {
        if (lesson.beginDate != null) {
          DateTime current = DateTime.now();
          DateTime beginDate = DateUtil.getDateTime(lesson.beginDate);
          if (current.isAfter(beginDate) == false) return false;
        }
        lesson.isLocked = false;
        valueNotifier.value = AiStudentClassVO.copy(currentClassVo);
//        valueNotifier.notifyListeners();
        return true;
      } else {
        lesson.stuState = 21;
        valueNotifier.notifyListeners();
      }
    }
    return false;
  }
}
