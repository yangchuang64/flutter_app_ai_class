import 'dart:async';

import 'package:blingabc_base/blingabc_base.dart';
import 'package:connectivity/connectivity.dart';

/// 找回密码view model
class FindpwdGetcodeViewModel {
  /// 检查手机号
  Future checkPhoneNumber(String phoneNum) {
    var completer = Completer();

    if (phoneNum.isEmpty || !Validators.phone(phoneNum)) {
      completer.completeError('请输入正确的手机号');
      return completer.future;
    }
    Connectivity().checkConnectivity().then((_result) {
      if (_result == ConnectivityResult.none) {
        completer.completeError("网络未连接");
        return;
      }
      completer.complete();
    });
    return completer.future;
  }

  /// 跳到下一步
  Future goNext(String phoneNum, String code) {
    var completer = Completer();

    if (phoneNum.isEmpty || !Validators.phone(phoneNum)) {
      completer.completeError('请输入正确的手机号');
      return completer.future;
    }
    if (code == null || code.length == 0) {
      completer.completeError("验证码不正确");
      return completer.future;
    }
//    Connectivity().checkConnectivity().then((_result) {
//      if (_result == ConnectivityResult.none) {
//        completer.completeError("网络未连接");
//        return;
//      }
////      _userService.verifyCode(phoneNum, code).then((baseResp) {
////        if (!baseResp.result) {
////          completer.completeError(baseResp.msg);
////          return;
////        }
////        completer.complete();
////      });
//
//    });
    completer.complete();
    return completer.future;
  }
}
