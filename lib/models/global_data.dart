//import 'package:flutter_app_ai_math/models/login_model.dart';
//import 'package:hive/hive.dart';
//
//const String LOGIN_INFO = 'login_info';
//
//class GlobalData {
//  Box _hiveBox;
//
//  LoginInfo _loginInfo;
//
//  get loginInfo => _loginInfo;
//
//  set loginInfo(loginInfo) => _loginInfo = loginInfo;
//
//  GlobalData() {
//    init();
//  }
//
//  init() async {
//    _hiveBox = await Hive.openBox(LOGIN_INFO);
//  }
//
//  /// 保存登陆信息
//  void saveLoginInfo(LoginInfo loginInfo) {
//    _loginInfo = loginInfo;
//    _hiveBox.put(LOGIN_INFO, _loginInfo.toJson().toString());
//  }
//}
