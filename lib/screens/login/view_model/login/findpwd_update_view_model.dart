import 'dart:async';

import 'package:blingabc_base/blingabc_base.dart' as base;
import 'package:flutter/cupertino.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';

/// 更新密码view model
class FindpwdUpdateViewModel {
  GlobalKey<FormState> phoneFormKey = new GlobalKey<FormState>();
  GlobalKey<FormState> phoneCodeFormKey = new GlobalKey<FormState>();
  String password; //第一次密码
  String conformPassword; //第二次密码
  bool isRequesting = false;

  /// 检查输入的信息是否正确
  Future<BaseResp> updatePassword(String phoneNum, String phoneCode, String password, String conformPassword) {
    var completer = Completer<BaseResp>();

    if (password.length == 0 || conformPassword.length == 0) {
      completer.completeError("请补全密码");
      return completer.future;
    }
    if (password != conformPassword) {
      completer.completeError("两次密码不一致");
      return completer.future;
    }
    bool valid = base.Validators.isValidPassword(password);
    if (!valid) {
      completer.completeError("请输入6-12位数字字母组合密码");
      return completer.future;
    }

    if (isRequesting == true) {
      completer.completeError("正在请求");
      return completer.future;
    }
    isRequesting = true;

    Map<String, dynamic> param = {
      'mobile': phoneNum,
      'verifyCode': phoneCode,
      'password': password,
    };
//    _userService.updatePassword(param).then((respond) => completer.complete(respond)).whenComplete(() => isRequesting = false);
//    http_post(ApiConfigs.findPassword, param).then((resp) => completer.complete(resp)).whenComplete(() => isRequesting = false);

    return completer.future;
  }
}
