import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart' as R;

import 'router_handler.dart';

/// 路由跳转监控对象
/// 1.state 继承 [RouteAware]
/// 2 didChangeDependencies 添加 routeObserver.subscribe(this, ModalRoute.of(context));
/// 3 在dispose 添加 routeObserver.unSubscribe(this);
/// 4 重写路由事件 [didPopNext], [didPush], [didPop], [didPushNext]
final R.RouteObserver<R.PageRoute> routeObserver = R.RouteObserver<R.PageRoute>();

///
/// Rout控制器，页面注册控制
/// 页面注册逻辑
/// 1· 配置PagePath路径名
/// 2· 在[routerMap]中注册刚配置的PagePath路径名
/// 3· 在[Intent]中文件下面解析page跳转是的参数解析
/// 4· 如果需要设置入场方式变更在[RouterManager] 匹配设置，默认 TransitionType.inFromRight
/// 5· 使用 -> Navigator.pushNamed(context, PagePath.aiMath, arguments: param)
///
class PagePath {
  static const splash = '/'; // 闪屏
  static const login = "login";
  static const path = '/path'; // 课时路径
  static const aiDetail = '/ai_detail'; // ai课
  static const beforeAiPage = 'pathBeforeClassPage'; // 课前课后页面
  static const aiFinish = '/ai_finish'; // ai课完成页面
  static const evaluateCourse = '/evaluateCourse'; // 评价课程
  static const feedback = '/feedback'; // 问题反馈
  static const babyInformation = '/babyInformation'; // 宝贝信息
  static const setting = '/setting'; // 设置
  static const howToHaveClass = '/howToHaveClass'; // 如何上课
}

/// route.map注册表
final Map<String, Handler> routerMap = {
//  PagePath.splash: splashHandler,
  PagePath.login: loginHandler,
  PagePath.path: pathHandler,
  PagePath.aiDetail: aiDetailHandler,
  PagePath.aiFinish: aiFinishHandler,
  PagePath.evaluateCourse: evaluateCourseHandler,
  PagePath.feedback: feedbackHandler,
  PagePath.babyInformation: babyInformationHandler,
  PagePath.beforeAiPage: beforeClassHandler,
  PagePath.setting: settingHandler,
  PagePath.howToHaveClass: howToHaveClassHandler,
};
