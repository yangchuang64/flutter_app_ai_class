import 'dart:convert';

import 'package:blingabc_base/blingabc_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/routers/router_config.dart';
import 'package:flutterblingaiplugin/screen/configs/plugin_login_user_info.dart';
import 'package:flutterblingaiplugin/screen/uitils/local_data.dart';
import 'package:flutterblingaiplugin/screen/uitils/log.dart';
import 'package:provider/provider.dart';

///
/// 登录用户信息模型
///
class LoginUserInfo extends ChangeNotifier {
  LoginUserInfo._() : super() {
    init();
  }

  static LoginUserInfo _instance;

  /// 顶层路由导航的key 用于获取Navigator对象
  static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  ///
  /// 获取单利对象
  /// [context] 当 context == null是，为Provoder.value初始化
  static LoginUserInfo getInstance(BuildContext context) {
    if (context == null) {
      if (_instance == null) _instance = LoginUserInfo._();
      return _instance;
    }
    return Provider.of<LoginUserInfo>(context, listen: false);
  }

  /// 登陆信息
  LoginInfo _loginInfo;

  LoginInfo get loginInfo => _loginInfo;

  /// 当前选择用户
  StudentInfo _selectedStudent;

  StudentInfo get selectedStudent => _selectedStudent;

  /// 更新属性值后发通知
  void updateWhenChangedValue() => notifyListeners();

  /// 退出登录，返回登录界面，并清空登录用户信息
  static void gotoLoginPageWhenLogOut() {
    _instance.clearLoginInfo();
    NavigatorState navigatorState = navigatorKey.currentState;
    navigatorState.pushReplacementNamed(PagePath.login);
  }

  init() {
    String loginInfoStr = local_data_get(LOCAL_DATA_LOGIN_INFO);
    printLog('ai_log', '_hiveBox loginInfoStr ${loginInfoStr}');
    if (!isNullOrEmpty(loginInfoStr)) {
      _loginInfo = LoginInfo.fromJson(jsonDecode(loginInfoStr));
    }

    String selectedStudentNum = local_data_get(LOCAL_DATA_SELECTED_STUDENT_NUM);
    if (!isNullOrEmpty(selectedStudentNum)) {
      _loginInfo?.studentList?.forEach((studentInfo) {
        if (studentInfo.stuNum == selectedStudentNum) {
          _selectedStudent = studentInfo;
        }
      });
    }
//    /// todo  test
//    _selectedStudent.stuNum = "421352211";
//    /// todo  test
    _updatePluginUserIfo();
  }

  /// 更新登陆信息
  void updateLoginInfo(LoginInfo loginInfo) {
    _loginInfo = loginInfo;
    _selectedStudent = loginInfo.studentList[0];
    local_data_put(LOCAL_DATA_LOGIN_INFO, jsonEncode(_loginInfo));
     printLog('ai_log', '_hiveBox LOCAL_DATA_LOGIN_INFO ${local_data_get(LOCAL_DATA_LOGIN_INFO)}');
    _updatePluginUserIfo();
  }

  /// 更新当前学生信息
  void updateSelectedStudent(StudentInfo studentInfo) {
    _selectedStudent = studentInfo;
    local_data_put(LOCAL_DATA_SELECTED_STUDENT_NUM, studentInfo.stuNum);
     printLog('ai_log', '_hiveBox LOCAL_DATA_SELECTED_STUDENT_NUM ${local_data_get(LOCAL_DATA_SELECTED_STUDENT_NUM)}');
    _updatePluginUserIfo();
    notifyListeners();
  }

  /// 清理本地登录的用户信息
  void clearLoginInfo() {
    _loginInfo = null;
    local_data_put(LOCAL_DATA_LOGIN_INFO, null);
    // printLog('ai_log', '_hiveBox LOCAL_DATA_LOGIN_INFO ${local_data_get(LOCAL_DATA_LOGIN_INFO)}');
    _selectedStudent = null;
    local_data_put(LOCAL_DATA_SELECTED_STUDENT_NUM, null);
    // printLog('ai_log', '_hiveBox LOCAL_DATA_SELECTED_STUDENT_NUM ${local_data_get(LOCAL_DATA_SELECTED_STUDENT_NUM)}');
  }

  /// 同步到plugin里面
  void _updatePluginUserIfo() {
    if (_selectedStudent == null) return;
    PluginLoginUserInfo.stuNum = _selectedStudent.stuNum;
    PluginLoginUserInfo.name = _selectedStudent.name;
    PluginLoginUserInfo.token = _loginInfo.token;
    PluginLoginUserInfo.navigatorKey = navigatorKey;
    PluginLoginUserInfo.handleTokenIsInvalid = () {
      Future.delayed(Duration(seconds: 1), () => LoginUserInfo.gotoLoginPageWhenLogOut());
    };
  }
}

///
/// 对所有需要取登录用户数据的UI全都要使用LoginUserWidget嵌套，
/// 或者自己使用[Consumer]嵌套,当数据用户更新时，嵌套的[builder]重建刷新
///
class LoginUserWidget extends StatelessWidget {
  final Widget Function(BuildContext context, LoginUserInfo value, Widget child) builder;
  final Widget child;

  LoginUserWidget({@required this.builder, this.child}) {
    assert(this.builder != null, "LoginUserWidget.builder需要赋值");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginUserInfo>(
      child: this.child ?? Container(),
      builder: this.builder,
    );
  }
}
