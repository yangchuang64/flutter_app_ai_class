import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/validators.dart';
import 'package:package_info/package_info.dart';

class LoginViewModel {
  Future sendSms(String phone, String uuid) {
    var completer = Completer<BaseRespData>();
    NetRequest.post(
      url: ApiConfigs.sendSms,
      param: {'mobile': phone},
      headers: {'uuid': uuid},
    ).then((resp) {
      if (!resp.result) {
        completer.completeError(resp.msg);
        return;
      }

      completer.complete(resp.data as BaseRespData);
    });
    return completer.future;
  }

  Future<LoginInfo> loginWithSmsCode(String phone, String smsCode) {
    var completer = Completer<LoginInfo>();
    if (!Validators.phone(phone)) {
      completer.completeError("请输入正确的手机号码");
      return completer.future;
    }
    if (!Validators.required(smsCode)) {
      completer.completeError("请输入验证码");
      return completer.future;
    }

    var params = {'mobile': phone, 'smsCode': smsCode};
//    http_post(ApiConfigs.loginWithSmsCode, params).then((res) {
//      if (res.code != HTTP_CODE_SUCCESS) {
//        completer.completeError(res.msg);
//        return;
//      }
//
//      LoginInfo userModel = LoginInfo.fromJson(res.data);
//      completer.complete(userModel);
//    });
    NetRequest.post(
      url: ApiConfigs.loginWithSmsCode,
      param: params,
      dateTypeInstance: LoginInfo(),
    ).then((resp) {
      if (!resp.result) {
        completer.completeError(resp.msg);
        return;
      }

//      LoginInfo userModel = LoginInfo.fromJson(res.data);
      LoginInfo loginInfo = resp.data as LoginInfo;
      completer.complete(loginInfo);
    });
    return completer.future;
  }

  Future loginWithPassword(String phone, String password) {
    var completer = Completer();
    if (!Validators.phone(phone)) {
      completer.completeError("请输入正确的手机号码");
      return completer.future;
    }
    if (!Validators.required(password)) {
      completer.completeError("请输入密码");
      return completer.future;
    }

    var params = {'mobile': phone, 'pwd': password};
//    http_post(ApiConfigs.loginWithPassword, params).then((res) {
//      if (res.code != HTTP_CODE_SUCCESS) {
//        completer.completeError(res.msg);
//        return;
//      }
////      _statisticsAction.sendLoginEvent(LoginWay.passwordLogin);
//
//      LoginInfo userModel = LoginInfo.fromJson(res.data);
////      _saveUserInfo(userModel);
//      completer.complete(userModel);
//    });
    NetRequest.post(
      url: ApiConfigs.loginWithPassword,
      param: params,
      dateTypeInstance: LoginInfo(),
    ).then((resp) {
      if (!resp.result) {
        completer.completeError(resp.msg);
        return;
      }

      LoginInfo loginInfo = resp.data as LoginInfo;
//      NetRequest.get(
//        url: ApiConfigs.studentList,
//        param: {'parentNum': loginInfo.parentNum},
//      ).then((resp) {
//        if (resp.result) {
//          List<StudentInfo> students = ((resp.data as BaseRespData).originValue as List)?.map((e) => e == null ? null : StudentInfo.fromJson(e as Map<String, dynamic>))?.toList();
//
//          loginInfo.studentList.forEach((studentInfo) {
//            students.forEach((studentInfo2) {
//              if (studentInfo.stuNum == studentInfo2.stuNum) {
//                studentInfo.active = studentInfo2.active;
//              }
//            });
//          });
//        }
//
//      });
      completer.complete(loginInfo);
    });
    return completer.future;
  }

//  /// 手机拨号获取验证码
//  Future<BaseResp> getVerifyCodeByDialPhone(String phone) {
//    return http_get('', phone);
//  }

  void loginLog(String parentPhone, String parentNum) async {
    String deviceName;
    String deviceVersion;
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      deviceName = iosInfo.systemName;
      deviceVersion = iosInfo.systemVersion;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      deviceName = androidInfo.id;
      deviceVersion = androidInfo.version.release;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var params = {
      'parentPhone': parentPhone,
      'parentNum': parentNum,
      'deviceName': deviceName,
      'deviceVersion': deviceVersion,
      'appVersion': packageInfo.version,
    };
    NetRequest.post(
      url: ApiConfigs.logiLog,
      param: params,
      dateTypeInstance: LoginInfo(),
    );
  }
}
