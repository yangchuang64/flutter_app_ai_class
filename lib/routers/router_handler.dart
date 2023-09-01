import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/screens/ai_class_detail/finish_page.dart';
import 'package:flutter_app_ai_math/screens/classesPath/path_before_class_page.dart';
import 'package:flutter_app_ai_math/screens/classesPath/path_page.dart';
import 'package:flutter_app_ai_math/screens/login/login_page.dart';
import 'package:flutter_app_ai_math/screens/personal_center/pages/baby_information_page.dart';
import 'package:flutter_app_ai_math/screens/personal_center/pages/evaluate_course_page.dart';
import 'package:flutter_app_ai_math/screens/personal_center/pages/feedback_page.dart';
import 'package:flutter_app_ai_math/screens/personal_center/pages/settings_page.dart';
import 'package:flutter_app_ai_math/screens/classesPath/how_to_have_class_page.dart';
import 'package:flutterblingaiplugin/screen/ai_class_detail/aiClass_detail_page2.dart';

///
/// Rout控制器，参数解析控制
///
typedef Widget HandlerFunc(BuildContext context, Map<String, List<String>> parameters);
typedef Widget IntentBuilder(params);

class Intent {
  final IntentBuilder builder;
  HandlerFunc handlerFunc;

  Intent({this.builder}) {
    this.handlerFunc = (context, _) {
      return this.builder(ModalRoute.of(context).settings.arguments as Map<String, dynamic>);
    };
  }

  Handler getHandler() => Handler(handlerFunc: this.handlerFunc);
}

///
/// 一下是注册的route参数解析

///// 闪屏
//Handler splashHandler = Intent(builder: (params) => SplashPage()).getHandler();

/// 登录页面
Handler loginHandler = Intent(builder: (params) => LoginPage()).getHandler();

/// 路径
Handler pathHandler = Intent(builder: (params) => PathPage()).getHandler();

/// ai数学视频
Handler aiDetailHandler = Intent(
  builder: (params) => AiClassDetailPage(
    params["classId"],
    params["classLessonId"],
    params["classLessonName"],
    params["resourceId"],
    params["lessonId"],
    oldAiId: params["oldAiId"],
    previewModel: params["previewModel"],
    finishedState: params["finishedState"],
  ),
).getHandler();

/// 课前课后页面
Handler beforeClassHandler = Intent(
  builder: (params) => PathBeforeClassPage(
    params["classId"],
    params["classLessonId"],
    params["classLessonName"],
    params["subjectCode"],
    params["lessonType"],
    classLessonNum: params["classLessonNum"],
  ),
).getHandler();

/// ai完成界面
Handler aiFinishHandler = Intent(
  builder: (params) {
    var aiLessonId = params["aiLessonId"];
    if (aiLessonId is String) aiLessonId = int.parse(aiLessonId);
    return FinishPage(
      aiLessonId,
      params["subjectCode"],
      params["classLessonId"],
      params["oldAiId"],
    );
  },
).getHandler();

/// 评价课程界面
Handler evaluateCourseHandler = Intent(
  builder: (params) => EvaluateClassPage(
    lessonId: params["lessonId"],
    lessonName: params["lessonName"],
    classLessonId: params["classLessonId"],
    classLessonName: params["classLessonName"],
  ),
).getHandler();

/// 问题反馈
Handler feedbackHandler = Intent(builder: (params) => FeedBackPage()).getHandler();

/// 宝贝信息
Handler babyInformationHandler = Intent(builder: (params) => BabyInformationPage()).getHandler();

/// 设置
Handler settingHandler = Intent(builder: (params) => SettingPages()).getHandler();

/// 如何上课
Handler howToHaveClassHandler = Intent(builder: (params) => HowToHaveClassPage()).getHandler();
